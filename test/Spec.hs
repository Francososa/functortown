{-# LANGUAGE OverloadedStrings #-}

import Lib

import Data.Bifunctor
import Data.Char
import Hedgehog
import qualified Hedgehog.Gen as Gen
import qualified Hedgehog.Range as Range


pair_id :: Property
pair_id =
  property $ do
    xs <- forAll $ Gen.list (Range.linear 0 100) Gen.alpha
    ys <- forAll $ Gen.list (Range.linear 0 100) Gen.alpha
    fmap id (Pair xs ys) === id (Pair xs ys)

pair_comp :: Property
pair_comp =
  property $ do
    x <- forAll $ Gen.integral (Range.linear 0 100)
    y <- forAll $ Gen.integral (Range.linear 0 100)
    composedNum (Pair x y) === fcomposedNum (Pair x y)


backward_id :: Property
backward_id =
  property $ do
    xs <- forAll $ Gen.list (Range.linear 0 100) Gen.alpha
    ys <- forAll $ Gen.list (Range.linear 0 100) Gen.alpha
    fmap id (BackwardPair xs ys) === id (BackwardPair xs ys)

backward_comp :: Property
backward_comp =
  property $ do
    x <- forAll $ Gen.integral (Range.linear 0 100)
    y <- forAll $ Gen.integral (Range.linear 0 100)
    composedNum (BackwardPair x y) === fcomposedNum (BackwardPair x y)


inc_id :: Property
inc_id =
  property $ do
    x  <- forAll $ Gen.integral (Range.linear 0 100)
    ys <- forAll $ Gen.list (Range.linear 0 100) Gen.alpha
    fmap id (IncrementPair x ys) === id (IncrementPair x ys)

inc_comp :: Property
inc_comp =
  property $ do
    x <- forAll $ Gen.integral (Range.linear 0 100)
    y <- forAll $ Gen.integral (Range.linear 0 100)
    composedNum (IncrementPair x y) === fcomposedNum (IncrementPair x y)
    

tuple_id :: Property
tuple_id =
  property $ do
    x <- forAll $ Gen.element ['a'..'z']
    y <- forAll $ Gen.int (Range.constant minBound maxBound)
    bimap id id (x,y) === id (x,y)

either_id :: Property
either_id =
  property $ do
    x <- forAll $ Gen.string (Range.linear 0 100) Gen.ascii
    y <- forAll $ Gen.int (Range.constant minBound maxBound)
    bimap id id (Right y :: Either String Int) === id (Right y)
    bimap id id (Left x :: Either String Int) === id (Left x)


these_id :: Property
these_id =
  property $ do
    x <- forAll $ Gen.string (Range.linear 0 100) Gen.ascii
    y <- forAll $ Gen.int (Range.constant minBound maxBound)
    bimap id id (This x :: These String Int) === id (This x)
    bimap id id (That y :: These String Int) === id (That y)
    bimap id id (These x y) === id (These x y)
    

tuple_comp :: Property
tuple_comp =
  property $ do
    x <- forAll $ Gen.element ['a'..'z']
    y <- forAll $ Gen.int (Range.constantFrom 0 minBound maxBound)
    bimap toUpper abs (x,y) === (first toUpper . second abs) (x,y)

these_comp :: Property
these_comp =
  property $ do
    x <- forAll $ Gen.element ['a'..'z']
    y <- forAll $ Gen.int (Range.constantFrom 0 minBound maxBound)
    bimap toUpper abs (This x :: These Char Int) === first toUpper (This x)
    bimap toUpper abs (That y :: These Char Int) === second abs (That y)
    bimap toUpper abs (These x y) === (first toUpper . second abs) (These x y)


tests :: IO ()
tests =
  do
    checkParallel $ Group "Pair Functor Tests" [
        ("pair id", pair_id),
        ("pair composition", pair_comp)
      ]
    checkParallel $ Group "IncrementPair Functor Tests" [
        ("increment id", inc_id),
        ("increment compposition", inc_comp)
      ]
    checkParallel $ Group "Bifunctor Identity Tests" [
        ("tuple", tuple_id),
        ("left and right", either_id),
        ("this, that and these", these_id)
      ]
    checkParallel $ Group "Bifunctor Composition Tests" [
        ("tuple", tuple_comp),
        ("this, that and these", these_comp)
      ]
    return ()
