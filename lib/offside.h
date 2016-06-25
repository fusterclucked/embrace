// NOTE: the autobrace and autosemi functions are combined
//       since autosemi depends on the autobrace indentation level
//       but must generate code before autobrace does

typedef struct Offside Offside;
struct Offside {
	size_t level;
	size_t depth;
	bool stmt;
	bool rhs;
	struct {
		char type;
		int indent;
	} prev;
};

void offside_open (Offside* this) {
	this->level = 0;
	this->depth = 0;
	this->stmt = false;
	this->rhs = false;
	this->prev.type = '\0';
	this->prev.indent = 0;
}

void write_rbrace (int level) {
	for ( int i = 0; i < level; i++ ) {
		fprintf (stdout, " }");
	}
}

void offside_write (Offside* this, Token* token) {
	int indent = (token->type != '\n') ? 0 :
		YYCURSOR - (token->text + 1) - this->level;

	this->level += indent;

	bool semi = (
		( (token->type == '\n' and indent <= 0) or token->type == '}'
		) and this->prev.type != ',' and this->prev.type != ';' and this->stmt
	) or (
		// TODO: suppress after dedent for comma line continuation or explicit semicolon
		( (this->prev.type == '\n' and this->prev.indent < 0) or this->prev.type == '}'
		) and this->rhs
	);

	if ( semi or token->type == ';' ) {
		this->rhs = false;
	}

	switch ( token->type ) {
		case '\n':
		case ':':
		this->stmt = false;
		break;

		case '=':
		this->rhs = true;
		break;

		case '{':
		this->depth++;
		this->stmt = false;
		break;

		case '}':
		this->depth--;
		this->stmt = false;
		break;

		case 'a':
		this->stmt = true;
		break;
	}

	if ( semi ) {
		fprintf (stdout, ";");
	}

	if ( this->depth == 0 ) {
		if ( indent > 0 ) {
			fprintf (stdout, " {");
		} else if ( indent < 0 ) {
			write_rbrace (-indent);
		}
	}

	this->prev.type = token->type;
	this->prev.indent = indent;
}

void offside_write_end (Offside* this) {
	if ( this->prev.type != ';' and this->stmt ) {
		fprintf (stdout, ";");
	}

	write_rbrace (this->level);
}
