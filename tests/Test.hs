module Main where

import Common

import Test.Tasty
import Paths_adder

main :: IO ()
main = do
  testsFile     <- getDataFileName "tests/tests.json"
  yourTestsFile <- getDataFileName "tests/yourTests.json"

  adderTests <- readTests testsFile
  yourTests  <- readTests yourTestsFile

  let tests = testGroup "Tests" [ testGroup "Adder"      adderTests
                                , testGroup "Your-Tests" yourTests
                                ]

  defaultMain tests

readTests :: FilePath -> IO [TestTree]
readTests f = fmap createTestTree <$> parseTestFile f
