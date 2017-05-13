
##############################################################
# PROJECT

s = Framer.Importer.load("imported/Job Application Concept Designs@1x")
document.body.style.cursor = "auto"
Framer.Extras.Hints.disable()

##############################################################
# GLOBAL

animationOptionsSpring = {curve: Spring(damping: 0.5), time: 0.5}
animationOptionsEase = {curve: Bezier.ease, time: 0.3}
Framer.Defaults.Animation = {curve: Spring(damping: 1), time: 0.3}

iOSBackgroundBlurStyle = "-webkit-backdrop-filter": "blur(32px)"
supportsCSSBackdropFilter = CSS.supports("(-webkit-backdrop-filter: blur())")

opacityTransition = (nav, layerA, layerB, overlay) ->
	transition =
		layerB: 
			show: {point: nav.point, opacity: 1}
			hide: {point: nav.point, opacity: 0}

Array::lastObject = -> @[@length - 1]

##############################################################
# STYLE

s.detail.backgroundColor = "transparent"

generatePropsForItem = (item) ->
	props =
		image: s["#{item.name}Photos"].children[0].image
		borderRadius: 16
		style: "box-shadow": "inset 0 0 0 1px rgba(0,0,0,0.16)"
	return props

for item in s.items.children
	item.props = generatePropsForItem(item)

s.info.props = 
	style: iOSBackgroundBlurStyle, clip: true
	backgroundColor: "rgba(0,0,0,0.4)"
s.map.borderRadius = 24

s.pagesBG.borderRadius = 38 / 2

##############################################################
# EVENTS

flow = new FlowComponent size: Screen.size
flow.showNext(s.search, animate: false)
s.statusBar.parent = null

# ------------------------------------------------------------
# MAIN SCREEN

for item in s.items.children
	item.onTap ->
		@openDetail()

# ------------------------------------------------------------
# DETAIL SCREEN

Layer::openDetail = () ->
	photos = s["#{@name}Photos"]?.children
	if !photos then return
	
	s.detail.item = @
	s.statusBarBlack.animate opacity: 0
	@originalPoint = @point
	@originalSize = @size
	@bringToFront()
	point = Screen.convertPointToLayer({x: 0, y: 0}, s.items)
	@animate size: flow.size, borderRadius: 0, point: point
	flow.transition(s.detail, opacityTransition)
	
	s.pages.opacity = 0
	s.pagesBG.opacity = 0
	
	s.info.props = x: -Screen.width, y: 0, parent: s.detail
	s.info.placeBefore(s.pagesBG)
	
	photoSlider = createPhotoSlider(photos)
	
	Utils.delay 0.5, ->
		photoSlider.opacity = 1
		s.pages.animate opacity: 1
		s.pagesBG.animate opacity: 1

createPhotoSlider = (photos) ->
	photosSlider = new PageComponent 
		size: s.detail.size, parent: s.detail
		scrollHorizontal: true, scrollVertical: false
		backgroundColor: "black", opacity: 0
	if !s.detail.photosSliders then s.detail.photosSliders = []
	s.detail.photosSliders.push photosSlider
	photosSlider.sendToBack()
	
	emptyPage = new Layer size: photosSlider.size 
	photosSlider.addPage(emptyPage, "right")
	for item in photos
		photoContainer = new Layer size: photosSlider.size, clip: true
		photo = new Layer 
			size: photosSlider.size, image: item.image
			parent: photoContainer
		photosSlider.addPage(photoContainer, "right")
		photoContainer.x += 4
	photosSlider.updateContent()
	firstPhoto = photosSlider.content.children[1]
	photosSlider.snapToPage(firstPhoto, false)
	
	for i in [1..photos.length]
		circle = s.circle.copySingle()
		circle.parent = s.pages
		circle.x = (circle.width + 18) * i
		if i == 1
			circle.opacity = 1
		else
			circle.opacity = 0.4
		s.pages.lastCircle = circle
	s.circle.opacity = 0.4
	s.pages.width = s.pages.lastCircle.maxX
	s.pagesBG.width = s.pages.lastCircle.maxX + 18 * 2
	s.pages.centerX()
	s.pagesBG.centerX()
	
	photosSlider.onMove ->
		offsetX = @x
		
		currentPage = Math.round(Utils.modulate(offsetX, [0, -@width], [0, @children.length], true))
		if photosSlider.currentPage != currentPage
			for item, i in s.pages.children
				if i == currentPage 
					item.opacity = 1
				else
					item.opacity = 0.4
		if 0 >= offsetX >= -Screen.width
			firstPhoto.children[0].x = 0
		opacity = Utils.modulate(offsetX, [0, -754], [0, 1], true)
		s.infoIcon.opacity = opacity
		s.bottomHeader.opacity = opacity
		s.info.x = offsetX
		
		for layer, i in @children
			layer.children[0]?.x = Utils.modulate(offsetX, [-754*(i-1), -754*(i+1)], [-300, 300], true)
	
	return photosSlider

s.closeIcon.onTap ->
	s.statusBarBlack.animate opacity: 1
	flow.showPrevious()
	s.detail.item.animate 
		borderRadius: 16, size: s.detail.item.originalSize
		point: s.detail.item.originalPoint
	Utils.delay 0.5, ->
		s.info.props = x: 2000
		for item in s.detail.photosSliders
			item.destroy()
		for item, i in s.pages.children
			if i != 0 then item.destroy()

