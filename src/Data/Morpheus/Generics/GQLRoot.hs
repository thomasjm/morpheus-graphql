{-# LANGUAGE DefaultSignatures , OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables , MultiParamTypeClasses, RankNTypes , DisambiguateRecordFields , FlexibleInstances , FlexibleContexts , TypeOperators #-}

module Data.Morpheus.Generics.GQLRoot
    ( GQLRoot(..)
    )
where

import           Control.Monad
import           Data.List                      ( find )
import           Data.Data                      ( Data
                                                , Typeable
                                                , typeOf
                                                , TypeRep
                                                )
import           Data.Text                      ( Text(..)
                                                , pack
                                                )
import qualified Data.Map                      as M

import           GHC.Generics
import           Data.Morpheus.Types.Types      ( SelectionSet
                                                , QuerySelection(..)
                                                , GQLQueryRoot(..)
                                                , ResolveIO(..)
                                                , failResolveIO
                                                )
import Data.Morpheus.Types.JSType (JSType(..))
import Data.Morpheus.Types.MetaInfo (MetaInfo(..), initialMeta)
import           Data.Morpheus.Generics.GQLArgs ( GQLArgs(..) )
import           Data.Morpheus.Types.Introspection
                                                ( GQL__Type(..)
                                                , GQL__Field
                                                , GQL__TypeKind(..)
                                                , GQL__InputValue
                                                , GQLTypeLib
                                                , GQL__EnumValue
                                                , createType
                                                , createField
                                                , emptyLib
                                                )
import           Data.Morpheus.Generics.TypeRep ( Selectors(..) )
import           Data.Proxy
import           Data.Morpheus.Generics.GenericMap ( GenericMap(..) )
import           Data.Maybe                     ( fromMaybe )
import           Data.Morpheus.Schema.GQL__Schema
                                                ( initSchema
                                                , GQL__Schema
                                                )
import           Data.Morpheus.Generics.GQLSelection
                                                ( GQLSelection(..)
                                                , wrapAsObject
                                                , arrayMap
                                                )
import           Data.Morpheus.PreProcess       ( preProcessQuery )

setProperty :: Text -> JSType -> JSType -> JSType
setProperty name prop (JSObject obj) = JSObject (M.insert name prop obj)

getProperty :: Text -> QuerySelection -> Maybe QuerySelection
getProperty name (SelectionSet _ sel) = lookup name sel

unpackObj (SelectionSet _ sel) = sel

class GQLRoot a where

    encode :: a -> GQLQueryRoot  ->  ResolveIO JSType
    default encode :: ( Generic a, Data a, GenericMap (Rep a) , Show a) => a -> GQLQueryRoot -> ResolveIO JSType
    encode rootResolver query =  case preProcessQuery schema query of
        Right validGQL -> case getProperty "__schema" validGQL of
            Nothing -> response
            Just value ->  addSchema value response
            where
                item (SelectionSet _ x) = wrapAsObject (encodeFields initialMeta x (from $ initSchema $ M.elems schema))
                response = wrapAsObject $ encodeFields initialMeta (unpackObj validGQL) (from rootResolver)
                addSchema value = liftM2 (setProperty "__schema") (item value)

        Left x ->  failResolveIO x
        where
            schema = introspectRoot (Proxy :: Proxy a);

    introspectRoot :: Proxy a  -> GQLTypeLib
    default introspectRoot :: (Show a, Selectors (Rep a) GQL__Field , Typeable a) => Proxy a -> GQLTypeLib
    introspectRoot _ = do
        let typeLib = introspect (Proxy:: Proxy GQL__Schema) emptyLib
        arrayMap (M.insert "Query" (createType "Query" fields) typeLib) stack
               where
                   fieldTypes  = getFields (Proxy :: Proxy (Rep a))
                   stack = map snd fieldTypes
                   fields = map fst fieldTypes ++ [ createField "__schema" "__Schema" [] ]