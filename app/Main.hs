module Main where

import HighLow
import HighLowExample (applyList)
import LIO
import LIO.TCB (showTCB)

main :: IO ()
main = do
    results <- runHL $ do
        -- A list of labeled inputs: public (Low) and secret (High) numbers.
        inputs <-
            sequence
                [ label Low 42
                , label High 100
                , label Low 11
                , label Low 55
                , label High 77
                ]
        applyList inputs

    -- 'Labeled' has no 'Show' instance by design; trusted code uses 'showTCB'
    -- to inspect the value together with its label (printed as @value {label}@).
    putStrLn "applyList results (value {label}):"
    mapM_ (putStrLn . ("  " ++) . showTCB) results
