import qualified Data.ByteString.Lazy as B
import qualified Data.ByteString.Builder as B
import Data.Foldable
import System.Process
import Text.Printf
import Data.List

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
  map (* volume) $ zipWith3 (\x y z -> x * y * z) release attack output
  where
    step = (hz * 2 * pi) / sampleRate
    
    attack :: [Pulse]
    attack = map (min 1.0) [0.0, 0.001 ..]
    
    release :: [Pulse]
    release = reverse $ take (length output) attack
    
    output :: [Pulse]
    output = map sin $ map (* step) [0.0 .. sampleRate * duration]

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

