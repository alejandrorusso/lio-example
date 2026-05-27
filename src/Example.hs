module Example
  ( runExample
  ) where

import LIO
import LIO.DCLabel

-- | A small LIO computation using DCLabels.
--
-- We create two labeled values protected by principals @alice@ and @bob@
-- respectively, then combine them. The resulting current label reflects
-- that information from both principals has been observed.
example :: DC (Int, DCLabel)
example = do
  let aliceL = "alice" %% True
      bobL   = "bob"   %% True

  secretA <- label aliceL (40 :: Int)
  secretB <- label bobL   (2  :: Int)

  a <- unlabel secretA
  b <- unlabel secretB

  cur <- getLabel
  return (a + b, cur)

-- | Run the example computation in IO. Starts at label 'dcPublic'
-- with the clearance of @True %% False@ (top clearance).
runExample :: IO ()
runExample = do
  (result, finalLabel) <- evalDC example
  putStrLn $ "Result:       " ++ show result
  putStrLn $ "Final label:  " ++ show finalLabel
