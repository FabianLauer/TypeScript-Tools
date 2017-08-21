##
## Updates index.ts files.
##

DIR = process.argv[2]

setImmediate () -> main()

fs = require 'fs'

# Returns all names of `.ts` files in a certain directory, except `index.ts`.
get_file_names_in_dir = (dirPath) ->
	records = fs.readdirSync dirPath
	return records.filter (rec) -> /\.ts/.test(rec) && rec != 'index.ts'

# Checks if a file has a default export symbol or not.
has_default_export = (fileContent) ->
	return /export +default +/.test fileContent

class DefaultImportStatement
	constructor: (fileName, importName) ->
		this.fileName = fileName
		this.importName = importName
	
	toString: () -> "import #{this.importName} from './#{this.fileName}';"

class ImportStatement extends DefaultImportStatement
	toString: () -> "import * as #{this.importName} from './#{this.fileName}';"

main = () ->
	importStrings = []
	exportNames = []
	fileNames = get_file_names_in_dir(DIR)
	fileNames.forEach (fileName) ->
		file = fs.readFileSync(DIR + '/' + fileName).toString();
		nameWithoutExtension = fileName.replace(/\.ts$/, '')
		exportNames.push nameWithoutExtension
		if has_default_export file
			importStrings.push new DefaultImportStatement(nameWithoutExtension, nameWithoutExtension)
		else
			importStrings.push new ImportStatement(nameWithoutExtension, nameWithoutExtension)
	exportNames = exportNames.map (exportName) -> '\t' + exportName
	fs.writeFileSync(
		DIR + '/index.ts',
		importStrings.join('\n') + '\n\n' +
		'export {\n' +
		exportNames.join(',\n') + '\n' +
		'}\n'
	)

