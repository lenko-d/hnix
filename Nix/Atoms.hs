module Nix.Atoms where

import Prelude
import Data.Text (Text, pack)
import GHC.Generics
import Data.Data
import Data.HashMap.Strict (HashMap)

-- | Atoms are values that evaluate to themselves. This means that
-- they appear in both the parsed AST (in the form of literals) and
-- the evaluated form.
data NAtom
  -- | An integer. The c nix implementation currently only supports
  -- integers that fit in the range of 'Int64'.
  = NInt !Integer
  -- | Booleans.
  | NBool !Bool
  -- | Null values. There's only one of this variant.
  | NNull
  -- | URIs, which are just string literals, but do not need quotes.
  | NUri !Text
  deriving (Eq, Ord, Generic, Typeable, Data, Show)

class ToAtom t where
  toAtom :: t -> NAtom

instance ToAtom Bool where toAtom = NBool
instance ToAtom Int where toAtom = NInt . fromIntegral
instance ToAtom Integer where toAtom = NInt

class FromAtom t where
  fromAtom :: NAtom -> t
  fromAtoms :: [NAtom] -> t
  fromAtomSet :: HashMap Text NAtom -> t

-- | Convert a primitive into something which can be made from a
-- constant. So for example `convert 1 :: Expression`
convert :: (ToAtom prim, FromAtom t) => prim -> t
convert = fromAtom . toAtom

-- | Conversion to environment variables for constants.
atomToEnvString :: NAtom -> Text
atomToEnvString = \case
  NInt i -> pack $ show i
  NBool True -> "1"
  NBool False -> ""
  NNull -> ""
  NUri uri -> uri
