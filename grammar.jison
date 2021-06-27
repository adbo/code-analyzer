%{
    const readline = require('readline');

    const read = type => {
        let result;
        const rl = readline.createInterface({
            input: process.stdin,
            output: process.stdout
        });


        rl.on('pause', () => {
            console.log('Paused Event is invoked');
        });

        s = `Please provide a ${type}: `
        rl.question(s, answer => {
            console.log(answer);
            result = answer;

            rl.close();
        });
        console.log('\n');
        return result;
    }

    const values = {};

    const assign = (id, value, type) => {
        if (id in values) {
            item = values[id];
            if (item.type === type) {
                item.value = value || (type === "NUM" ? 0 : "");
            } else {
                throw `Invalid type expected ${item.type} instead got ${type}.`;
            }
        } else {
            values[id] = {
                value: value || (type === "NUM" ? 0 : ""),
                type: type
            }
        }
    }

    const calculate = (a, op, b) => {
        let result;
        switch (op) {
            case "+":
                result = Number(a) + Number(b); break;
            case "-":
                result = a - b; break;
            case "*":
                result = a * b; break;
            case "/":
                result = a / b; break;
            case "%":
                result = a % b; break;
        }
        return result;
    }

    const print = (expression) => {
        let result;
        if (expression in values) {
            result = values[expression].value;
        } else {
            result = expression;
        }
        console.log(result);

        return result;
    }

    const clearString = s => s.split('"').join('');

    const position = (str1, str2) => {
        s1 = clearString(str1);
        s2 = clearString(str2);
        return s1.indexOf(s2);
    }
    
    const concatenate = (str1, str2) => {
        s1 = clearString(str1);
        s2 = clearString(str2);
        return s1.concat(s2);
    }

    const substring = (str, pos, len) => {
        s = clearString(str);
        return s.substr(pos, len);
    }

    const compare = (arg1, arg2, op) => {
        let result;
        switch(op) {
            case "=":
                result = (arg1 === arg2); break;
            case "<":
                result = (arg1 < arg2); break;
            case "<=":
                result = (arg1 <= arg2); break;
            case ">":
                result = (arg1 > arg2); break;
            case ">=":
                result = (arg1 >= arg2); break;
            case "<>":
                result = (arg1 !== arg2); break;
        }
        return result;
    }
%}

%lex

%%
\s+                   /* skip whitespace */
";"                   return ";";
","                   return ",";
"exit"                return "exit";
"readint"             return "readint";
"readstr"             return "readstr";
"and"                 return "and";
"or"                  return "or";
"true"                return "true";
"false"               return "false";
"if"                  return "if";
"then"                return "then";
"else"                return "else";
"begin"               return "begin";
"end"                 return "end";
"do"                  return "do";
"while"               return "while";
"print("              return "print(";
"length("             return "length("
"position("           return "position("
"concatenate("        return "concatenate("
"substring("          return "substring("
"("                   return "(";
")"                   return ")";
":="                  return ":=";
"!="                  return "!=";
"=="                  return "==";
"<="                  return "<=";
">="                  return ">=";
"<>"                  return "<>";
"="                   return "=";
"<"                   return "<";
">"                   return ">";
"+"                   return "+";
"-"                   return "-";
"*"                   return "*";
"/"                   return "/";
"%"                   return "%";
[a-zA-Z0-9]+          return "IDENT";
[0-9]+                return "NUM";
\"(\\.|[^"\\])*\"     return "STRING";          


/lex

%start program

%% /* language grammar */

num_op
    : "+" | "-" | "*" | "/" | "%";

bool_op
    : "and" | "or";

num_rel
    : "=" | "<" | "<=" | ">" | ">=" | "<>";

str_rel
    : "==" | "!=";

bool_expr
    : "true" | "false"
    | "(" bool_expr ")"
        {$$ = $2;}
    | "not" bool_expr
        {$$ = ($2 === "true" ? "false" : "true");}
    | bool_expr bool_op bool_expr
        {$$ = ($2 === "and" ? $1 && $3 : $1 || $3);}
    | num_expr num_rel num_expr
        {$$ = compare($1, $3, $2);}
    | str_expr str_rel str_expr
        {$$ = ($2 === '==' ? $1 === $3 : $1 !== $3);}
    ;

num_expr
    : NUM
    | IDENT
    | "(" num_expr ")"
        {$$ = $2;}
    | "readint"
        {$$ = read("number");}
    | "-" num_expr
        {$$ = calculate($2, '*', -1);}
    | num_expr num_op num_expr
        {$$ = calculate($1, $2, $3);}
    | "length(" str_expr ")"
        {$$ = $2.length-2;}
    | "position(" str_expr "," str_expr ")"
        ${$$ = position($2, $4);}
    ;

str_expr
    : STRING 
    | IDENT
    | "readstr"
        {$$ = read("string");}
    | "concatenate(" str_expr "," str_expr ")"
        {$$ = concatenate($2, $4);}
    | "substring(" str_expr "," num_expr "," num_expr ")"
        {$$ = substring($2, $4+1, $6);}
    ;

simple_instr
    : assign_stat
    | if_stat
    | while_stat
    | "begin" instr "end"
        {$$ = $2;}
    | output_stat
    | "exit"
        {process.exit(0);}
    | num_expr
    ;

instr
    : instr ";" simple_instr
    | simple_instr
    ;

assign_stat
    : IDENT ":=" num_expr
        {$$ = assign($1, $3, "NUM");}
    | IDENT ":=" str_expr
        {$$ = assign($1, $3, "STRING");}
    ;

if_stat
    : "if" bool_expr "then" simple_instr
    | "if" bool_expr "then" simple_instr "else" simple_instr
    ;

while_stat
    : "while" bool_expr "do" simple_instr
    | "do" simple_instr "while" bool_expr
    ;

output_stat
    : "print(" num_expr ")"
        {$$ = print($2);}
    | "print(" str_expr ")"
        {$$ = print($2);}
    | "print(" bool_expr ")"
        {$$ = print($2);}
    ;

program
    : instr
    ;