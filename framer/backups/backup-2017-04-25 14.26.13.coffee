
# PROJECT
##############################################################

sketch = Framer.Importer.load("imported/Design@1x")

{dpr} = require 'DevicePixelRatio'

Framer.Extras.Hints.disable()
document.body.style.cursor = "auto"
Screen.backgroundColor = "#A6EFDF"

# UTILS
##############################################################

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
		fixSizeWithChildren(layer, resetPoint)

Layer::fixSize = (resetPoint = false) ->
	fixSize(@, resetPoint)

PageComponent::fixSize = (resetPoint = false) ->
	fixSize(@, resetPoint)

Layer::fit = (whiteSpace = 0) ->
	@width = Screen.width
	for item in this.children
		item.fixSize()
		item.centerX()
	desktop = sketch["#{this.name}Desktop"]
	mobile = sketch["#{this.name}Mobile"]
	if desktop and mobile
		isMobile = desktop.width > (Screen.width - dpr(whiteSpace) * 2)
		desktop.visible = !isMobile
		mobile.visible = isMobile
	updateHeight(@)

calculateTrueMaxY = (layer, desktopMargin = 0, mobileMargin = 0) ->
	if mobileMargin is 0 then mobileMargin = desktopMargin
	desktop = sketch["#{layer.name}Desktop"]
	mobile = sketch["#{layer.name}Mobile"]
	if desktop and mobile
		if desktop.visible
			return layer.y + desktop.maxY + dpr(desktopMargin)
		else
			return layer.y + mobile.maxY + dpr(mobileMargin)
	else
		maxY = layer.height
		if layer.children.length > 0 then maxY = 0
		for item in layer.children
			if item.visible
				temp = calculateTrueMaxY(item)
				if temp > maxY
					maxY = temp
		if Utils.isMobile()
			return layer.y + maxY + dpr(mobileMargin)
		else
			return layer.y + maxY + dpr(desktopMargin)
	return layer.y + maxY + dpr(desktopMargin)

updateHeight = (layer) ->
	layer.height = calculateTrueMaxY(layer) - layer.y

convertToGallery = (layer, whiteSpace = 0) ->
	if layer.constructor.name isnt "PageComponent"
		pageComponent = convertToPageComponent(layer, true)
		pageComponent.name = layer.name
		sketch[layer.name] = pageComponent
		pageComponent.originX = 0
		pageComponent.fixSize()
		makeSmall = Screen.height < pageComponent.height + dpr(64)
		x = 0
		for item in layer.children
			item.fixSize(makeSmall)
			item.parent = pageComponent.content
			if makeSmall
				item.x = x
				x += dpr(8) + item.width
		layer.destroy()
		layer = pageComponent
		if makeSmall
			layer.height = 10
			layer.updateContent()
			layer.height = layer.content.height
	maxWidth = Screen.width - dpr(whiteSpace) * 2
	if layer.content.width >= maxWidth
		layer.scrollHorizontal = true
		layer.width = maxWidth
	else
		layer.scrollHorizontal = false
	layer.centerX()

convertToScrollComponent = (layer, isHorizontal = false) ->
	parent = layer.parent
	index = layer.index
	scrollComponent = ScrollComponent.wrap(layer)
	scrollComponent.props =
		scrollHorizontal: isHorizontal
		scrollVertical: !isHorizontal
		parent: parent
		directionLock: true
		directionLockThreshold: { x: 50, y: 50 }
		mouseWheelEnabled: true
	scrollComponent.index = index
	return scrollComponent

convertToPageComponent = (layer, isHorizontal = false) ->
	parent = layer.parent
	index = layer.index
	pageComponent = PageComponent.wrap(layer)
	pageComponent.props =
		scrollHorizontal: isHorizontal
		scrollVertical: !isHorizontal
		parent: parent
		directionLock: true
		directionLockThreshold: { x: 50, y: 50 }
		mouseWheelEnabled: true
	pageComponent.index = index
	return pageComponent

Layer::inspect = () ->
	bg = new Layer 
		size: this.size
		backgroundColor: "blue"
		parent: this
		x: 0, y: 0, opacity: 0.5

# VARIABLES
##############################################################

animationOptionsSpring = {curve: Spring(damping: 0.5), time: 0.5}
animationOptionsEase = {curve: Bezier.ease, time: 0.3}

main = sketch.main
backgroundVideo = null

madeWithOffset = sketch.madeWithIcons.height / 2

# STYLE
##############################################################

main.backgroundColor = null
sketch.linksPopup.opacity = 0
sketch.madeWithIconsColored.props =
	visible: true, opacity: 0, y: madeWithOffset

# LAYOUT
##############################################################

sketch.bg.parent = null
sketch.bg.sendToBack()

sketch.thereIsMore.fixSize()
for link, i in sketch.links.children.reverse()
	link.fixSize()
	link.props = x: dpr(i * (48 + 16)), y: 0
sketch.links.fixSize()

sketch.gallery.clip = true

fixSizeWithChildren(sketch.footer, false)

setLayout = () ->
	# Main
	main.size = Screen.size

	# Background
	videoAspectRatio = 1280 / 720
	backgroundVideoSize = Screen.size
	if Screen.width / Screen.height >= videoAspectRatio
		backgroundVideoSize.height = Screen.width / videoAspectRatio
	else
		backgroundVideoSize.width = Screen.height * videoAspectRatio
	sketch.bg.size = backgroundVideoSize
	sketch.bg.center()
	
	if !backgroundVideo
		backgroundVideo = new VideoLayer
			video: "videos/timelapse.mp4", backgroundColor: "transparent"
		backgroundVideo.sendToBack()
	backgroundVideo.size = backgroundVideoSize
	backgroundVideo.center()
	
	# Header
	sketch.info.fit(32)
	sketch.info.center()
	sketch.info.y -= sketch.thereIsMore.height / 2 + sketch.links.height / 2
	sketch.info.originalPosition = sketch.info.point
	
	sketch.links.centerX()
	sketch.links.y = sketch.info.maxY + dpr(32)
	
	sketch.linksPopup.y = sketch.links.maxY + dpr(16)
	
	sketch.thereIsMore.centerX()
	sketch.thereIsMore.maxY = Screen.height - dpr(32)
	sketch.thereIsMore.originalPosition = sketch.thereIsMore.point
	
	# Gallery
	sketch.gallery.width = Screen.width
	sketch.gallery.y = Screen.height + dpr(64, 32)
	sketch.gallery.centerX()
	
	sketch.section1.width = Screen.width
	sketch.title1.fit(32)
	sketch.title1.centerX()
	convertToGallery(sketch.items1, 32)
	sketch.items1.y = sketch.title1.maxY + dpr(32)
	
	
	sketch.section2.y = calculateTrueMaxY(sketch.section1, 64)
	sketch.section2.width = Screen.width
	sketch.title2.fit(32)
	sketch.title2.centerX()
	sketch.items2.width = Screen.width
	sketch.items2.y = sketch.title2.maxY + dpr(32)
	convertToGallery(sketch.items2_1, 32)
	sketch.items2_1.y = 0
	convertToGallery(sketch.items2_2, 32)
	sketch.items2_2.y = calculateTrueMaxY(sketch.items2_1, 8)
	
	sketch.playIcon.fixSize()
	sketch.playIcon.center()
	updateHeight(sketch.items2)
	
	updateHeight(sketch.gallery)
	
	# See More
	sketch.seeMore.fixSize()
	sketch.seeMore.centerX()
	sketch.seeMore.y = calculateTrueMaxY(sketch.gallery, 64)

	# Footer
	sketch.footer.fixSize()
	sketch.footer.centerX()
	sketch.footer.y = sketch.seeMore.maxY + dpr(64)
setLayout()

if Utils.isMobile()
	main = convertToScrollComponent(main)
else
	main.scrollVertical = true

# EVENTS
##############################################################

Events.wrap(backgroundVideo.player).on "canplay", ->
	sketch.bg.animate opacity: 0

backgroundVideo.player.autoplay = true
backgroundVideo.player.loop = true

Events.wrap(window).addEventListener "resize", (event) ->
	setLayout()

Layer::makeLink = (link) ->
	this.clip = true
	this.html = "<a class='#{@name}' href='#{link}' target='_blank'></a>"
	Utils.insertCSS """
		.#{@name} {
			height: #{dpr(64)}px;
			width: #{dpr(64)}px;
			display: block;
		}
	"""
	this.ignoreEvents = false

sketch.medium.makeLink("http://medium.com/@einancunlu")
sketch.github.makeLink("http://github.com/einancunlu")
sketch.angelList.makeLink("http://angel.co/einancunlu")
sketch.cv.makeLink("https://cl.ly/k2wZ")
sketch.seeMore.makeLink("https://cl.ly/jcQS")
if Utils.isMobile()
	sketch.playIcon.makeLink("https://cl.ly/jbwD")
else
	sketch.videoItem.makeLink("https://cl.ly/jbwD")

Layer::addMouseOverDetail = () ->
	point = @point
	@onMouseOver ->
		newSize = dpr(64)
		diff = (newSize - @width) / 2
		@parent.oldOpacity = @parent.opacity
		@parent.animate opacity: 1, options: animationOptionsSpring
		@animate 
			width: newSize, height: newSize, x: point.x - diff, y: point.y - diff
			options: animationOptionsSpring
		popup = sketch.linksPopup
		for layer in popup.children
			layer.visible = false
		sketch["linksPopup#{@name[0].toUpperCase() + @name[1..-1]}"]?.visible = true
		pointInMain = sketch.links.convertPointToLayer(point, main)
		pointInMain.x += dpr(24)
		pointInMain.y = sketch.links.maxY + dpr(16)
		popup.y = pointInMain.y
		if popup.opacity is 0 
			popup.midX = pointInMain.x
			popup.animate opacity: 1, options: animationOptionsEase
		else 
			popup.animate midX: pointInMain.x, opacity: 1, options: animationOptionsEase
	@onMouseOut ->
		size = dpr(48)
		@parent.animate opacity: @parent.oldOpacity, options: animationOptionsSpring
		@animate 
			width: size, height: size, point: point
			options: animationOptionsSpring
		sketch.linksPopup.animate
			opacity: 0, options: animationOptionsSpring
for layer in sketch.links.children
	layer.addMouseOverDetail()

sketch.madeWithIcons.onMouseOver ->
	sketch.madeWithIconsSaturated.animate opacity: 0, y: -madeWithOffset, options: animationOptionsEase
	sketch.madeWithIconsColored.animate opacity: 1, y: 0, options: animationOptionsEase
sketch.madeWithIcons.onMouseOut ->
	sketch.madeWithIconsSaturated.animate opacity: 1, y: 0, options: animationOptionsEase
	sketch.madeWithIconsColored.animate opacity: 0, y: madeWithOffset, options: animationOptionsEase

scrollEvent = () ->
	offsetY = main.scrollY
	scrollPercentage = Utils.modulate(offsetY, [0, Screen.height], [0, 1])
	
	sketch.info.y = sketch.info.originalPosition.y + offsetY / 2.2
# 	sketch.info.blur = 32 * scrollPercentage
# 	sketch.info.opacity = 1 - scrollPercentage
	
	sketch.links.y = sketch.info.maxY + dpr(32)
	sketch.links.opacity = 1 - scrollPercentage * 1.2
	
	middleY = (sketch.links.maxY + sketch.gallery.y) / 2 - sketch.thereIsMore.height / 2
	if middleY >= sketch.thereIsMore.originalPosition.y
		sketch.thereIsMore.y = middleY
	sketch.thereIsMore.opacity = 1 - scrollPercentage * 1.5

if Utils.isMobile()
	main.onMove ->
		scrollEvent()
else
	main.onScroll ->
		scrollEvent()

# PLAYGROUND
##############################################################

return

color = "rgba(80, 227, 194, 0.7)"

b = new Layer size: Screen.size, backgroundColor: "50E3C2", opacity: 0.7
b.style = "mix-blend-mode": "color"
a = new Layer
a.html = "<video height='#{Screen.height}' src='videos/timelapse.mp4' autoplay='true'></video>"

sketch.bac.destroy()
fontName = "Mandali"
raleway = Utils.loadWebFont(fontName)

title = new TextLayer
	text: "Emin Inanc Unlu"
	font: "800 48px/1 #{fontName}"
	color: "white"
	point: Align.center

previewSecond = Utils.modulate(rewindHandle.x, [92, 283], [0, videoPreviewDefault.player.duration])

opacityCycle = Utils.cycle([0, 1])
sketch.recentDesigns.opacity = 0
sketch.recentDesigns.animate opacity: 1
sketch.recentDesigns.onAnimationEnd ->
	@animate opacity: opacityCycle(), options: time: 1

convertToTextLayer = (layer) ->
	t = new TextLayer
		name: layer.name
		frame: layer.frame
		parent: layer.parent
	
	cssObj = {}
	css = layer._info.metadata.css
	css.forEach (rule) ->
		return if _.includes rule, '/*'
		arr = rule.split(': ')
		cssObj[arr[0]] = arr[1].replace(';','')
	t.style = cssObj
	
	importPath = layer.__framerImportedFromPath
	if _.includes importPath, '@2x'
		t.fontSize *= 2
		t.lineHeight = (parseInt(t.lineHeight)*2)+'px'
		t.letterSpacing *= 2
					
	t.y -= (parseInt(t.lineHeight)-t.fontSize)/2 # compensate for how CSS handles line height
	t.y -= t.fontSize * 0.1 # sketch padding
	t.x -= t.fontSize * 0.08 # sketch padding
	t.width += t.fontSize * 0.5 # sketch padding

	t.text = layer._info.metadata.string
	layer.destroy()
	return t