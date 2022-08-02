{-
  Kush Bharakhada

  Module allows ciphering text using Caesar Cipher and cracking ciphered text,
  showing how many shifts are required to return the text to its original state.
-}
module CaesarCipher where

  -- IMPORTS
  import Data.Char (toLower, toUpper, isLower, isUpper, ord, digitToInt, isDigit)
  import Data.List (sortOn)

  -- TYPE DECLARATIONS
  type Letter = Char
  type Freq = Int
  type LetterFreq = [(Letter, Freq)]
  
  -- FREQUENCY

  -- Letter frequency in english text / dictionary multipled by 1000
  -- (multiplied to make them integers)
  freqE :: LetterFreq
  freqE = [('a', 8200), ('b', 1500), ('c', 2800), ('d', 4300), ('e', 13000),
          ('f', 2200), ('g', 2000), ('h', 6100), ('i', 7000), ('j', 150),
          ('k', 770), ('l', 4000), ('m', 2400), ('n', 6700), ('o', 7500),
          ('p', 1900), ('q', 95), ('r', 6000), ('s', 6300), ('t', 9100),
          ('u', 2800), ('v', 980), ('w', 2400), ('x', 150), ('y', 2000),
          ('z', 274)]
  
  -- Counts a letter in a string
  nLetters :: String -> Char -> Int
  nLetters str c = length $ filter (== c) str

  -- Counts every letter in a string
  freqT :: String -> LetterFreq
  freqT str = [(c, nLetters lowStr c) | c <- "abcdefghijklmnopqrstuvwxyz"]
              where lowStr = map toLower str

  -- Multiplies the integer values of the tuple from two lists
  freqMult :: LetterFreq -> LetterFreq -> [Int]
  freqMult [] _ = []
  freqMult _ [] = []
  --  Recursively multiply the head of the resulting list
  freqMult (x:xs) (y:ys) = snd x * snd y : freqMult xs ys

  -- Sums the list of multiplied frequencies
  freqSum :: LetterFreq -> LetterFreq -> Int
  freqSum xs ys = sum $ freqMult xs ys

  -- SHIFTING

  char2Int :: Char -> Int
  char2Int c = ord c 

  int2Char :: Int -> Char
  int2Char n = toEnum n

  -- Allows alphabet letters to loop round back to start
  loop :: Char -> Char -> Int -> Char
  loop s c n = do 
    let sx = char2Int s; cx = char2Int c
    int2Char $ (cx + n - sx) `mod` 26 + sx

  -- Shifts a character
  shift :: Char -> Int -> Char
  shift c n | isLower c = loop 'a' c n
            | isUpper c = loop 'A' c n
            | otherwise = c
  
  -- SHIFT (CIPHER)

  -- Shift text
  shiftStr :: String -> Int -> String
  shiftStr str n = [shift c n | c <- str]

  -- SHIFT (DECIPHER) 

  -- Finds the sum for every shift (higher the more likely the shift)
  allShifts :: String -> [Int]
  allShifts str = [freqSum freqE $ freqT (shiftStr str n) | n <- [0..25]]

  -- Pairs the key with the sum for that shift 
  pairs :: String -> [(Int, Int)]
  pairs str = zip [0..25] $ allShifts str

  -- Key and value pairs ordered from most likely to least
  sortPairs :: String -> [Int]
  sortPairs str = do
    let r = [fst s | s <- sorted ] where sorted = sortOn snd $ pairs str
    reverse r
                 
  -- IO

  -- Prompts the user for text
  getText :: IO String
  getText = do
    putStrLn "Enter Text: "
    str <- getLine
    return str

  -- Prompts the user for a shift value
  getShift :: IO Int
  getShift = do 
    putStr "Enter a Key Shift Value: "
    x <- getLine
    if isInteger x then
      return (read x :: Int)
    else 
      do putStrLn "ERROR: Value Entered is NOT a Valid Integer!"
         getShift

  -- Checks if a value is an integer
  isInteger :: String -> Bool
  isInteger [] = False
  isInteger ns = and [isDigit n | n <- ns]

  -- Shifting text by a key, both provided by user
  shiftIO :: IO ()
  shiftIO = do
    str <- getText
    key <- getShift
    putStrLn $ shiftStr str key

  -- Displays the possible keys from most likely to least given some text
  findKeys :: IO ()
  findKeys = do
    str <- getText
    putStrLn $ printKey $ sortPairs str

  -- Helper to print the keys
  printKey :: [Int] -> String
  printKey ns = concat [show n ++ " Key shifts\n" | n <- ns]

  -- Prompts user to either shift or retrieve keys given text
  options :: IO ()
  options = do
    x <- getLine
    let y = x !! 0
    if y == 's' || y == 'S' then shiftIO
    else if y == 'k' || y == 'K' then findKeys
    else
      do putStrLn "Please provide a valid character"
         options -- Ask again if not valid


              


