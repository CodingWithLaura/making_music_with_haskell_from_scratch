import qualified Data.ByteString.Lazy as B
import qualified Data.ByteString.Builder as B
import Data.Foldable
import System.Process
import Text.Printf

type Pulse = Float
type Seconds = Float
type Samples = Float
type Hz = Float
type Semitones = Float

outputFilePath :: FilePath
outputFilePath = "output.bin"

volume :: Float
volume = 0.5

sampleRate :: Samples
sampleRate = 48000.0

pitchStandard :: Hz
pitchStandard = 440.0

f :: Semitones -> Hz
f n = pitchStandard * (2 ** (1.0 / 12.0)) ** n 

note :: Semitones -> Seconds -> [Pulse]
note n duration = freq (f n) duration

freq :: Hz -> Seconds -> [Pulse]
freq hz duration =
  map (* volume) $ map sin $ map (* step) [0.0 .. sampleRate * duration]
  where
    step = (hz * 2 * pi) / sampleRate

wave :: [Pulse]
wave = concat [ note 0  duration
              , note 2  duration
	      , note 4  duration
	      , note 5  duration
	      , note 7  duration
	      , note 9  duration
	      , note 11 duration
	      , note 12 duration
	      ]
  where
    duration = 0.5

save :: FilePath -> IO ()
save filePath = B.writeFile filePath $ B.toLazyByteString $ fold $ map B.floatLE wave

play :: IO ()
play = do
  save outputFilePath
  _ <- runCommand $ printf "ffplay -showmode 1 -f f32le -ar %f %s" sampleRate outputFilePath
  return ()

