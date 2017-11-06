opentype = require 'opentype.js'
argv = require('minimist')(process.argv)
fs = require 'fs'
inFile = argv.in
outFolder = argv.out or= './'

if argv.help is true
	console.log """
	Usage: iconfontpreview --in path/to/font/file

	Options:

	--in      path to font file
	--out     path to out folder (default is current folder)
	--help    help
	"""
	return

unless inFile or inFile is ''
	throw new Error 'No inFile specified'

console.log """

ICONFONTPREVIEW:
- Creating preview of #{inFile}
- Writing to #{outFolder}

"""

font = opentype.loadSync(inFile)

inFileName = inFile.split('/')
inFileName = inFileName[inFileName.length - 1]

fs.createReadStream(inFile).pipe(fs.createWriteStream(outFolder += inFileName))

# Node 8.5.0
# fs.copyFileSync(inFile, outFolder += '/fonts' + inFileName)

unicodeToChar = (unicode) -> String.fromCharCode(unicode)

fontName = font.names.preferredFamily.en

outputTable = ""

for index, glyph of font.glyphs.glyphs
	if glyph.unicode is undefined
		continue

	outputTable += """
		<div>
			<h1>#{unicodeToChar(glyph.unicode)}</h1>
			<p>Unicode: #{glyph.unicode}</p>
			<p>Name: #{glyph.name}</p>
			<p>Character: #{unicodeToChar(glyph.unicode)}</p>
		</div>
	"""

html = """
	<html>
		<head>
			<title>#{fontName} Preview</title>
			<style type="text/css">
				@font-face {
					font-family: #{fontName};
					src: url("./#{inFileName}"); 
				}

				body {
					font-family: Helvetica Neue, Helvetica, Arial, sans-serif;
					margin: 1em;
					background: #f9f9f9;
					color: #222;
				}

				#container div {
					float: left;
					width: 12.5%;
					margin: 1px;
					padding: 0.5em;
					background: #fff;
					height: 180px;
				}

				#container h1 {
					font-family: "#{fontName}";
				}

				#container p {
					color: #bbb;
					font-size: 0.65rem;
				}
			</style>
		</head>
		<body>
			<h1>#{fontName} Preview</h1>
			<div id="container">
				#{outputTable}
			</div>
		</body>
	</html>
"""

fs.writeFileSync('./preview.html', html)