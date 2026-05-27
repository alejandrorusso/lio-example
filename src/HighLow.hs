{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FlexibleInstances #-}

module HighLow (
    HL (..),
    NoPriv (..),
    HLIO,
    runHL,
    evalHL,
) where

import LIO.TCB

-- | The classic two-point security lattice: @Low ⊑ High@.
data HL = Low | High
    deriving (Eq, Ord, Show, Read)

instance Label HL where
    -- bottom / top
    lbot = Low
    ltop = High

    -- least upper bound (join): @High@ wins
    lub Low l = l
    lub l Low = l
    lub High _ = High

    -- greatest lower bound (meet): @Low@ wins
    glb High l = l
    glb l High = l
    glb Low _ = Low

    -- @x `leq` y@ iff @x ⊑ y@
    leq x y = x <= y

{- | This example uses no privileges. 'NoPriv' is the trivial (empty)
privilege; it exists only to instantiate the 'Priv'/'LabelState'
machinery that the legacy 'LIO l p s' monad requires.
-}
data NoPriv = NoPriv
    deriving (Eq, Show)

instance Semigroup NoPriv where
    _ <> _ = NoPriv

instance Monoid NoPriv where
    mempty = NoPriv

instance PrivTCB NoPriv

instance Priv HL NoPriv where
    -- With no privileges, the closest we can get to goal @g@ from @l@ is
    -- their join; this makes the default 'leqp' collapse to plain 'leq'.
    lostar _ l g = l `lub` g

-- | The label type functionally determines its privilege and state types.
instance LabelState HL NoPriv ()

-- | Convenient alias for LIO computations in the two-point lattice.
type HLIO = LIO HL NoPriv ()

{- | Run an 'HLIO' computation and return its result. Starts at the bottom
label @Low@ with clearance fixed to the top @High@ (the defaults set by
'newState').
-}
runHL :: HLIO a -> IO a
runHL m = fst <$> runLIO m (newState ())

-- | Like 'runHL', but also returns the final current label.
evalHL :: HLIO a -> IO (a, HL)
evalHL m = evalLIO m ()
