{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE FlexibleInstances    #-}

--------------------------------------------------------------------------------
-- | The entry point for the compiler: a function that takes a Text
--   representation of the source and returns a (Text) representation
--   of the assembly-program string representing the compiled version
--------------------------------------------------------------------------------

module Language.Adder.Compiler ( compiler ) where

import           Control.Arrow                   ((>>>))
import           Prelude                 hiding (compare)
import           Language.Adder.Types
import           Language.Adder.Parser     (parse)
import           Language.Adder.Asm        (asm)
import           Text.Printf (printf)

--------------------------------------------------------------------------------
compiler :: FilePath -> Text -> Text
--------------------------------------------------------------------------------
compiler f = parse f >>> compile >>> asm

--------------------------------------------------------------------------------
-- | The compilation (code generation) works with AST nodes labeled by @Tag@
--------------------------------------------------------------------------------
type Tag   = SourceSpan
type AExp  = Expr Tag

--------------------------------------------------------------------------------
-- | @compile@ a (tagged-ANF) expr into assembly
--------------------------------------------------------------------------------
compile :: AExp -> [Instruction]
--------------------------------------------------------------------------------
compile e = compileEnv emptyEnv e ++ [IRet]

--------------------------------------------------------------------------------
compileEnv :: Env -> AExp -> [Instruction]
--------------------------------------------------------------------------------
compileEnv _   (Number n _)     = [ IMov (Reg EAX) (repr n) ]
compileEnv env (Prim1 Add1 e _) = (compileEnv env e) ++ [IAdd (Reg EAX) (Const (1))]
compileEnv env (Prim1 Sub1 e _) = (compileEnv env e) ++ [IAdd (Reg EAX) (Const (-1))] 
compileEnv env (Id x l)         = [IMov (Reg EAX) (RegOffset (xn) (ESP))]
  where
    xn    = case lookupEnv x env of
              Just n  -> n * 4
              Nothing -> err
    err = panic (printf "Unbound variable %s" x) (l)
compileEnv env (Let x e1 e2 _)  = (compileEnv env e1) 
                               ++ [IMov (RegOffset (i*4) (ESP)) (Reg EAX)]
                               ++ (compileEnv env' e2)
  where
    (i, env')  = pushEnv x env

--------------------------------------------------------------------------------
-- | Representing Values
--------------------------------------------------------------------------------

class Repr a where
  repr :: a -> Arg

instance Repr Int where
  repr n = Const (fromIntegral n)

instance Repr Integer where
  repr n = Const (fromIntegral n)
