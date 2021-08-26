
; Class
((class_declaration
	name: (identifier) @class-name
	body: (class_body)) @scope-root)

; Function
((function_declaration
	name: (identifier) @function-name
	body: (statement_block)) @scope-root)

; Method
((method_definition
	name: (property_identifier) @method-name
	body: (statement_block)) @scope-root)
<<<<<<< HEAD
<<<<<<< HEAD
=======
=======
>>>>>>> af44664 (Trial of JS arrow function)

; Arrow Function
((variable_declarator
	name: (identifier) @function-name
	value: (arrow_function)) @scope-root)
<<<<<<< HEAD

; Function Expression
((variable_declarator
	name: (identifier) @function-name
	value: (function)) @scope-root)
>>>>>>> dfb0c22 (Add function expression query)
=======
>>>>>>> af44664 (Trial of JS arrow function)
