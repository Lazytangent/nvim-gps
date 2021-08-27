
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

; Arrow Function
((variable_declarator
	name: (identifier) @function-name
	value: (arrow_function)) @scope-root)

; Function Expression
((variable_declarator
	name: (identifier) @function-name
	value: (function)) @scope-root)

; Describe Callback
((call_expression
	function: (identifier) @function-name
	arguments: (arguments
		string: (string_fragment) @method-name
		(arrow_function
			parameters: (formal_parameters)
			body: (statement_block)) @scope-root)))
