
# PROJECT
##############################################################

sketch = Framer.Importer.load("imported/Design@1x")
{dpr} = require 'DevicePixelRatio'

Framer.Extras.Hints.disable()
document.body.style.cursor = "auto"
Screen.backgroundColor = "F5EFE9"

# GLOBAL
##############################################################

animationOptionsSpring = {curve: Spring(damping: 0.5), time: 0.5}
animationOptionsEase = {curve: Bezier.ease, time: 0.3}
Framer.Defaults.Animation = animationOptionsSpring

fontName = "Nunito"
Utils.loadWebFont(fontName)

fixSize = (layer, resetPoint = false) ->
	if !layer.originalFrame then layer.originalFrame = layer.frame
	layer.width = dpr(layer.originalFrame.width)
	layer.height = dpr(layer.originalFrame.height)
	if resetPoint
		layer.x = 0
		layer.y = 0
	else
		layer.x = dpr(layer.originalFrame.x)
		layer.y = dpr(layer.originalFrame.y)

fixSizeWithChildren = (layer, resetPoint = false) ->
	fixSize(layer, resetPoint)
	for item in layer.children
		fixSizeWithChildren(item, resetPoint)

Layer::inspect = () ->
	bg = new Layer 
		size: this.size
		backgroundColor: "blue"
		parent: this
		x: 0, y: 0, opacity: 0.5

# STYLE
##############################################################

sketch.pdfLink.image = null
sketch.pdfLink.props = 
	borderRadius: dpr(24), backgroundColor: "white", clip: true
pdfLinkNewBG = new Layer 
	parent: sketch.pdfLink, width: dpr(30), height: dpr(15)
	borderRadius: "50%", backgroundColor: "50E3C2", opacity: 0
pdfLinkNewBG.center()
pdfLinkNewBG.sendToBack()

# LAYOUT
##############################################################

fixSizeWithChildren(sketch.header)

for link, i in sketch.links.children.reverse()
	link.props = x: dpr(i * (48 + 16)), y: 0
	
	title = new TextLayer
		name: "#{link.name}Title", y: dpr(-8), scale: 0
		parent: sketch.links, text: link.name.toUpperCase()
		font: "800 italic #{dpr(12)}px #{fontName}"
		letterSpacing: 1.5, color: "black", opacity: 0
	title.midX = link.midX
	title.sendToBack()
	sketch[title.name] = title
	
	animationBG = new Layer 
		name: "#{link.name}AnimationBG"
		parent: sketch.links, size: link.size, point: link.point
		borderRadius: "50%", backgroundColor: "white"
		shadowY: dpr(16), shadowBlur: dpr(32), shadowColor: "rgba(0,0,0,0.0)"
	animationBG.sendToBack()
	sketch[animationBG.name] = animationBG

sketch.links.width = sketch.angelList.maxX
sketch.titleDesktop.sendToBack()
sketch.titleMobile.sendToBack()

setLayout = () ->
	sketch.main.size = Screen.size

	if Screen.size.width <= sketch.titleDesktop.width + dpr(64)
		sketch.titleMobile.visible = true
		sketch.titleDesktop.visible = false
		sketch.links.y = sketch.titleMobile.maxY + dpr(32)
	else
		sketch.titleMobile.visible = false
		sketch.titleDesktop.visible = true
		sketch.links.y = sketch.titleDesktop.maxY + dpr(42)
	
	sketch.divider.y = sketch.links.maxY + dpr(48)
	sketch.pdfLink.y = sketch.divider.maxY + dpr(48)
	
	sketch.header.props = 
		width: sketch.titleDesktop.width
		height: sketch.pdfLink.maxY
	sketch.header.center()

setLayout()

# EVENTS
##############################################################

Events.wrap(window).addEventListener "resize", (event) ->
	setLayout()

Layer::makeLink = (link) ->
	this.clip = true
	this.html = "<a class='#{@name}' href='#{link}' target='_blank'></a>"
	Utils.insertCSS """
		.#{@name} {
			height: #{dpr(1000)}px;
			width: #{dpr(1000)}px;
			display: block;
		}
	"""
	this.ignoreEvents = false
sketch.medium.makeLink("http://medium.com/@einancunlu")
sketch.github.makeLink("http://github.com/einancunlu")
sketch.linkedin.makeLink("http://linkedin.com/in/einancunlu/")
sketch.angelList.makeLink("http://angel.co/einancunlu")
sketch.pdfLink.makeLink("https://cl.ly/k2wZ")

addMouseOverDetail = (layer) ->
	label = sketch["#{layer.name}Title"]
	bg = sketch["#{layer.name}AnimationBG"]
	layer.onMouseOver ->
		bg.bringToFront()
		label.bringToFront()
		@bringToFront()
		label.animate opacity: 0.56, y: dpr(-16), scale: 1
		bg.animate 
			width: dpr(112), height: dpr(112), shadowColor: "rgba(0,0,0,0.04)"
			x: layer.x - dpr(32), y: layer.y - dpr(48)
	layer.onMouseOut ->
		@sendToBack()
		bg.sendToBack()
		label.sendToBack()
		label.animate opacity: 0, y: dpr(0), scale: 0
		bg.animate 
			width: dpr(48), height: dpr(48), shadowColor: "rgba(0,0,0,0.0)"
			x: layer.x, y: layer.y

for link, i in sketch.links.children[0..3]
	addMouseOverDetail(link)

sketch.pdfLink.onMouseOver ->
	pdfLinkNewBG.animate scale: 10, opacity: 1
	sketch.pdfLinkTitle.animate opacity: 0
	sketch.pdfLinkTitleWhite.animate opacity: 1

sketch.pdfLink.onMouseOut ->
	pdfLinkNewBG.animate scale: 1, opacity: 0
	sketch.pdfLinkTitle.animate opacity: 1
	sketch.pdfLinkTitleWhite.animate opacity: 0
