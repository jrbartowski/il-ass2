module SECD.Compile where

import SECD.AST
import Data.List (elemIndex)

compile :: Expr -> Sym -> Code
compile (Const k) _ = [LDC k]
compile (Var x) sym = case (elemIndex x sym) of
  (Just i) -> [LD i]
  (Nothing) -> error ("free variable: " ++ x)
compile (Add e1 e2) sym = (compile e1 sym) ++ (compile e2 sym) ++ [ADD]
compile (Sub e1 e2) sym = (compile e1 sym) ++ (compile e2 sym) ++ [SUB]
compile (Mul e1 e2) sym = (compile e1 sym) ++ (compile e2 sym) ++ [MUL]
compile (Div e1 e2) sym = (compile e1 sym) ++ (compile e2 sym) ++ [DIV]
compile (If e0 e1 e2) sym = (compile e0 sym) ++ [SEL c1 c2]
    where
        c1 = compile e1 sym ++ [JOIN]
        c2 = compile e2 sym ++ [JOIN]
compile (Lam x e) sym = [LDF ((compile e s1) ++ [RTN])]
    where
      s1 = (x:sym)
compile (App e1 e2) sym = (compile e1 sym) ++ (compile e2 sym) ++ [AP]
compile (Fix (Lam f (Lam x e))) sym = [LDRF ((compile e s1) ++ [RTN])]
    where s1 = (x:f:sym)
compile (Let var e1 e2) sym = compile (App (Lam var e2) e1) sym

compileProgram p = compile p [] ++ [HALT] -- compile a program and add HALT inst to the end
