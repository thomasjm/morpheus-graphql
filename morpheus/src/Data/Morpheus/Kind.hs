module Data.Morpheus.Kind
  ( GQLObject
  , GQLKind(description)
  , GQLQuery
  , GQLArgs
  , GQLInput
  , GQLEnum
  , GQLMutation
  , Scalar(..)
  ) where

import           Data.Morpheus.Kind.GQLArgs     (GQLArgs)
import           Data.Morpheus.Kind.GQLEnum     (GQLEnum)
import           Data.Morpheus.Kind.GQLInput    (GQLInput)
import           Data.Morpheus.Kind.GQLKind     (GQLKind (description))
import           Data.Morpheus.Kind.GQLMutation (GQLMutation (..))
import           Data.Morpheus.Kind.GQLObject   (GQLObject)
import           Data.Morpheus.Kind.GQLQuery    (GQLQuery (..))
import           Data.Morpheus.Kind.Scalar      (Scalar (parseValue, serialize))