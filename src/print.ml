open Syntax
open Printf
exception Unreachable
let rec print_program fmt p =
  fprintf fmt "[\n";
  pp_defs fmt p;
  fprintf fmt "]\n";
and pp_defs fmt = function
  |[] -> ()
  |x::xs ->
    let _ = pp_def fmt x in
    fprintf fmt ",\n";
    pp_defs fmt xs
and pp_def fmt = function
  | DefFun (ty, Name name, l1, b, (a, _)) ->
     fprintf fmt "Line:%d\nDefFun(int, %s, [%a], \n%a)"
             a.Lexing.pos_lnum name pp_dvars l1 pp_block b
  | DefVar d ->
     fprintf fmt "DefVar(%a)" pp_dvar d
and pp_types fmt l =
  let _ = List.map (pp_type fmt) l in
  ()
and pp_type fmt = function
  | TInt -> fprintf fmt "int,"
  | TPtr x -> fprintf fmt "*%a" pp_type x
  | TStruct (Some (Name nm), None) ->
     fprintf fmt "struct %s" nm
  | TStruct (Some (Name nm), Some dlist) ->
     fprintf fmt "struct %s {%a}" nm pp_dvars dlist
  | TStruct (None, Some dlist) ->
     fprintf fmt "struct {%a}" pp_dvars dlist
  | _ -> raise Unreachable
and pp_namelist fmt = function
  | [] ->
     fprintf fmt ""
  | (Name n)::ns ->
     fprintf fmt "%s," n;
     pp_namelist fmt ns
and pp_block fmt = function
  | Block (vs, s) -> fprintf fmt "\n{[local: %a],\n%a}\n" pp_dvars vs pp_stmts s
and pp_dvars fmt l =
  List.iter (pp_dvar fmt) l
and pp_dvar fmt = function
  | DVar (t, Name n, None)->
     fprintf fmt "(%a %s)," pp_type t n
  | DVar (t, Name n, Some x) ->
     fprintf fmt "(%a %s = %a)," pp_type t n pp_expr x
  | DArray (t, Name n, sz)->
     fprintf fmt "(%a%s[%d])," pp_type t n sz
  | DStruct (Name name, dlist) ->
     fprintf fmt "struct %s {%a}" name pp_dvars dlist
and pp_stmts fmt = function
  |[] -> ()
  |x::xs ->
    pp_stmt fmt x;fprintf fmt ",\n";pp_stmts fmt xs
and pp_stmt fmt = function
  | SNil ->
     fprintf fmt ";"
  | SBlock (dvs, stmts) ->
     fprintf fmt "SBlock(%a, %a)" pp_dvars dvs pp_stmts stmts
  | SWhile (e, b) ->
     fprintf fmt "SWhile(%a, %a)" pp_expr e pp_stmt b
  | SDoWhile (b, e) ->
     fprintf fmt "SDoWhile(%a, %a)" pp_stmt b pp_expr e
  | SFor (op1, op2, op3, s) ->
     fprintf fmt "SFor((%a; %a; %a), %a)" pp_op op1 pp_op op2 pp_op op3 pp_stmt s
  | SIfElse (e, b1, b2) ->
     fprintf fmt "SIfElse(%a, %a, %a)" pp_expr e pp_stmt b1 pp_stmt b2
  | SReturn e ->
     fprintf fmt "SReturn(%a)" pp_expr e
  | SContinue ->
     fprintf fmt "SContinue"
  | SBreak ->
     fprintf fmt "SBreak"
  | SLabel (str, st) ->
     fprintf fmt "SLabel(%s, %a)" str pp_stmt st
  | SGoto str ->
     fprintf fmt "SGoto %s" str
  | SSwitch (ex, st) ->
     fprintf fmt "SSwitch (%a, %a)" pp_expr ex pp_stmt st
  | SCase (ex) ->
     fprintf fmt "SCase (%a)" pp_expr ex
  | SDefault ->
     fprintf fmt "SDefault"
  | SExpr e ->
     fprintf fmt "SExpr(%a);" pp_expr e
and pp_op fmt = function
  | Some e -> pp_expr fmt e
  | None -> ()
and pp_exprs fmt= function
  | [] ->
     fprintf fmt ""
  | x::xs ->
     pp_expr fmt x;
     fprintf fmt ",";
     pp_exprs fmt xs;
and pp_expr fmt = function
  | EConst v ->
     fprintf fmt "EConst(%a)" pp_value v
  | EVar (Name str) ->
     fprintf fmt "EVar(%s)" str
  | EAdd (e1, e2) ->
     fprintf fmt "EAdd(%a, %a)" pp_expr e1 pp_expr e2
  | ESub (e1, e2) ->
     fprintf fmt "ESub(%a, %a)" pp_expr e1 pp_expr e2
  | ESubst (e1, e2) ->
     fprintf fmt "ESubst(%a, %a)" pp_expr e1 pp_expr e2
  | EAddr e ->
     fprintf fmt "EAddr(%a)" pp_expr e
  | EApp (Name s, args) ->
     fprintf fmt "EApp(%s, %a)" s pp_exprs args
  | ELe (e1, e2) ->
     fprintf fmt "ELe(%a, %a)" pp_expr e1 pp_expr e2
  | EEq (e1, e2) ->
     fprintf fmt "EEq(%a, %a)" pp_expr e1 pp_expr e2
  | ENeq (e1, e2) ->
     fprintf fmt "ENeq(%a, %a)" pp_expr e1 pp_expr e2
  | EPtr (e) ->
     fprintf fmt "EPtr(%a)" pp_expr e
  | EDot (e, Name nm) ->
     fprintf fmt "EDot(%a, %s)" pp_expr e nm
  | _ -> raise (TODO "print: pp_expr")
and pp_value fmt = function
  | VInt i ->
     fprintf fmt "VInt(%d)" i
