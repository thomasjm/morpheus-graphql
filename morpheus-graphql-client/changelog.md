# Changelog

## 0.15.0 - Unreleased Changes

### minor

- fixed client error on field `__typename` [#509](https://github.com/morpheusgraphql/morpheus-graphql/issues/509)

## 0.14.1 - 16.08.2020

### minor

- fixed Build error during testing [#5602](https://github.com/commercialhaskell/stackage/issues/5602)

## 0.14.0 - 15.08.2020

### new features

- supports interfaces.

- supports of block string values.

- support of `schema`. issue #412

  ```graphql
  schema {
    query: MyQuery
  }
  ```

- generated types have instance of class `Eq`

### breaking changes

- custom scalars Should Provide instance of class `Eq`

## 0.13.0 - 22.06.2020

### breaking changes

- from now you should provide for every custom graphql scalar definition corresponding haskell type definition and `GQLScalar` implementation fot it. for details see [`examples-client`](https://github.com/morpheusgraphql/morpheus-graphql/tree/master/examples-client)

- input fields and query arguments are imported without namespace

### new features

- exposed: `ScalarValues`,`GQLScalar`, `ID`

## 0.12.0 - 21.05.2020
