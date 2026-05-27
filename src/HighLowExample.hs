{- | Small examples of computing over 'Labeled' values in the two-point
@Low ⊑ High@ lattice (see "HighLow").
-}
module HighLowExample where

import HighLow
import LIO

{- |
 Double a labeled number, keeping the result at the /same/ label as the input.
-}
double :: Labeled HL Int -> HLIO (Labeled HL Int)
double lnumber =
    toLabeled (labelOf lnumber) $ do
        n <- unlabel lnumber
        return (n + n)

-- | A default secret
defaultVal :: HLIO (Labeled HL Int)
defaultVal = label High (0 :: Int)

-- | Dispatch on the /label/ of the input without observing its contents
testDispatch :: Labeled HL Int -> HLIO (Labeled HL Int)
testDispatch lint
    | labelOf lint == Low = double lint
    | labelOf lint == High = defaultVal

-- | Apply 'testDispatch' to every element of a list
applyList :: [Labeled HL Int] -> HLIO [Labeled HL Int]
applyList ls = sequence [testDispatch lv | lv <- ls]
