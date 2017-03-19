
##############################################################

# UTILITIES

animationOptionsSpring1 = {curve: "spring(300, 35, 0)"}
animationOptionsFastEase3 = {curve: "ease", time: 0.1}
animationOptionsFastEase2 = {curve: "ease", time: 0.15}
animationOptionsFastEase1 = {curve: "ease", time: 0.2}
animationOptionsEase = {curve: "ease", time: 0.3}

textFieldStyle =
	"font-family": "OpenSans";
	"font-size": "13px";
	"margin-left": "0px";
	"line-height": "21px";
	"color": "rgba(255,255,255,0.6)"

rightAlignedTextFieldStyle =
	"font-family": "OpenSans";
	"font-size": "13px";
	"margin-left": "0px";
	"line-height": "21px";
	"color": "rgba(255,255,255,0.6)"
	"text-align": "right"

rightAlignedEditedTextFieldStyle =
	"font-family": "OpenSans";
	"font-size": "13px";
	"margin-left": "0px";
	"line-height": "21px";
	"color": "rgba(255,255,255,0.8)"
	"text-align": "right"

alignLeft = (layers...) ->
	for layer in layers
		layer.x = Align.left
alignCenterX = (layers...) ->
	for layer in layers
		layer.x = Align.center
alignRight = (layers...) ->
	for layer in layers
		layer.x = Align.right
alignTop = (layers...) ->
	for layer in layers
		layer.y = Align.top
alignCenterY = (layers...) ->
	for layer in layers
		layer.y = Align.center
alignBottom = (layers...) ->
	for layer in layers
		layer.y = Align.bottom

convertToScrollComponent = (layer, isHorizontal = false) ->
	parent = layer.parent
	index = layer.index
	scrollComponent = ScrollComponent.wrap(layer)
	scrollComponent.props =
		scrollHorizontal: isHorizontal
		scrollVertical: !isHorizontal
		parent: parent
		directionLock: true
		#directionLockThreshold: { x: 100, y: 25 }
	scrollComponent.index = index
	return scrollComponent

Layer::convertToOpacityInvisible = () ->
	this.props = visible: true, opacity: 0

Layer::changeMouseOnHover = (mouseStyle) -> 
	this.onMouseOver ->
		if this.opacity == 0 then return
		document.body.style.cursor = mouseStyle
	this.onMouseOut ->
		document.body.style.cursor = "auto"

Layer::makeResizeable = (updatePositionFunction) ->
	this.changeMouseOnHover("ew-resize")
	this.draggable.enabled = true
	this.draggable.momentum = false
	this.draggable.pixelAlign = true
	this.draggable.updatePosition = (point) ->
		return updatePositionFunction(point)

Layer::makeMoveable = (updatePositionFunction) ->
	this.draggable.enabled = true
	this.draggable.momentum = false
	this.draggable.pixelAlign = true
	if !updatePositionFunction then return
	this.draggable.updatePosition = (point) ->
		return updatePositionFunction(point)

Layer::addMouseHoverState = (enableTapState = true, onTap) ->
	hover = sketch["#{this.name}Hover"]
	normal = sketch["#{this.name}Default"]
	this.onMouseOver ->
		hover.visible = true
		normal.visible = false
	this.onMouseOut ->
		hover.visible = false
		normal.visible = true
	if enableTapState 
		this.onTapStart ->
			hover.visible = false
			normal.visible = true
		this.onTapEnd ->
			hover.visible = true
			normal.visible = false
	if onTap
		this.onTap ->
			onTap()

Layer::addSizeConstraintModes = (onTap) ->
	this.on Events.Tap, (event) ->
		if 32 < event.pointY - 79 < 64
			sizeAll = sketch["#{this.name}All"]
			size320 = sketch["#{this.name}320"]
			size720 = sketch["#{this.name}720"]
			if event.pointX < 38
				if !sizeAll then return
				sizeAll?.visible = true
				size320?.visible = false
				size720?.visible = false
				onTap?(0)
			else if event.pointX < 38 * 2
				if !size320 then return
				size320?.visible = true
				sizeAll?.visible = false
				size720?.visible = false
				onTap?(1)
			else if event.pointX < 38 * 3
				if !size720 then return
				size720?.visible = true
				sizeAll?.visible = false
				size320?.visible = false
				onTap?(2)

Layer::addPreviewInspectionFeature = (indicatorLayer) ->
	this.onMouseOver ->
		indicatorLayer.visible = true
	this.onMouseOut ->
		indicatorLayer.visible = false

Layer::addTapState = (onTap) ->
	hover = sketch["#{this.name}Hover"]
	normal = sketch["#{this.name}Default"]
	this.onTapStart ->
		hover.visible = true
		normal.visible = false
	this.onTapEnd ->
		hover.visible = false
		normal.visible = true
	if onTap
		this.onTap ->
			onTap()

Layer::addTapToggleState = (onTap) ->
	other = sketch["#{this.name}Other"]
	normal = sketch["#{this.name}Default"]
	this.onTap ->
		other.visible = !other.visible
		normal.visible = !other.visible
		if onTap then onTap()

Layer::addOpacityToggleState = (opacity = 0, curve = "ease", time = 0.15) ->
	layer = this
	layer.visible = true
	layer.states =
		default: opacity: 1, ignoreEvents: false
		hidden: opacity: 0, ignoreEvents: true
	layer.states.animationOptions = curve: curve, time: time
	layer.on Events.StateSwitchStart, (from, to) ->
		if from is "hidden" then layer.x -= 5000
	layer.on Events.StateSwitchEnd, (from, to) ->
		if from is "default" then layer.x += 5000
	if opacity == 0 then layer.stateSwitch("hidden")

Layer::animateButtonTap = () ->
	normal = sketch["#{this.name}Default"]
	pressed = sketch["#{this.name}Pressed"]
	normal.visible = false
	pressed.visible = true
	Utils.delay 0.1, ->
		normal.visible = true
		pressed.visible = false
		
animateButtonTap = (layer) ->
	layer.visible = false
	sketch["#{layer.name}Clicked"].visible = true
	Utils.delay 0.1, ->
		layer.visible = true
		sketch["#{layer.name}Clicked"].visible = false

Layer::convertToScalableInspectorLayer = () ->
	this.image = null
	this.style = 
		background: "rgba(0,176,254,0.20)"
		border: "2px solid #00B0FF"

Layer::addShadow = (color = "rgba(0,0,0,0.16)", y = 4, blur = 16, spread = 0) ->
	this.props =
		shadowColor: color, shadowY: y
		shadowBlur: blur, shadowSpread: spread

##############################################################
# COMPONENTS

# SETUP

Framer.Extras.Hints.disable()
sketch = Framer.Importer.load("imported/Design@1x")

Framer.Defaults.Animation = animationOptionsSpring1
document.body.style.cursor = "auto"

sketch.firstTab.addMouseHoverState()
sketch.activeTab.addMouseHoverState()
sketch.thirdTab.addMouseHoverState()

windowFlow = new FlowComponent width: 1280, height: 800
#windowFlow.center()
windowFlow.showNext(sketch.window, animate: false, scroll: false)

popupOpen = null
activeComponentsListItem = sketch.componentListItem_mainScreen

# PREVIEW PANEL

viewMode = 1

previewDefaultSize = sketch.preview.size
previewDefaultPoint = sketch.preview.point
previewMaxX = sketch.preview.maxX

previewSmallDefaultWidth = 127
previewSmallModeIsOn = false

previewSnapPoints = [
	sketch.snapArea1, sketch.snapArea2
	sketch.snapArea3, sketch.snapArea4
]
snapToDeviceSizes = false

deviceSizes = [
	{ width: 320, height: 568, name: "iPhone SE" }
	{ width: 375, height: 667, name: "iPhone 7" }
	{ width: 414, height: 736, name: "iPhone 7 Plus" }
	{ width: 768, height: 1024, name: "iPad" }
	{ width: 1024, height: 1366, name: "iPad Pro" }
]
defaultDeviceIndex = 1
currentDeviceIndex = 1

previewAspectRatioIsOn = true
previewWidthIsChanging = true
previewManualResizingIsOn = false
previewManualResizingHappened = false

defaultPreviewFlowWidth = 375
defaultPreviewFlowRatio = 0.5622

###############################
# STYLE

sketch.previewAreaFrame.image = null
sketch.previewAreaFrame.style = "border": "2px solid #000000"

sketch.viewMode1.opacity = .6
sketch.viewMode2.opacity = .2
sketch.viewMode3.opacity = .2

###############################
# PREVIEW MOVING

sketch.preview.on "change:point", ->
	if !snapToDeviceSizes and viewMode == 1
		previewMaxX = sketch.preview.maxX
	if !sketch.previewMoveArea.isDragging
		sketch.previewMoveArea.x = sketch.preview.x + 64
		sketch.previewResizingAreaLeft.x = sketch.preview.x - 8
		sketch.previewResizingAreaTop.x = sketch.preview.x + 157
		sketch.previewMoveArea.y = sketch.preview.y
		sketch.previewResizingAreaLeft.y = sketch.preview.y + 32
		sketch.previewResizingAreaTop.y = sketch.preview.y - 8

sketch.previewMoveArea.makeMoveable (point) -> 
	deltaX = point.x - sketch.previewMoveArea.x
	deltaY = point.y - sketch.previewMoveArea.y
	sketch.preview.x += deltaX
	sketch.preview.y += deltaY
	return point

sketch.previewMoveArea.onDragEnd ->
	minDistance = null
	closestLayer = null
	panel = sketch.preview
	for layer in previewSnapPoints
		distance = Math.abs(layer.midX - panel.midX) + Math.abs(layer.midY - panel.midY)
		if !closestLayer then closestLayer = layer
		if !minDistance then minDistance = distance
		if distance < minDistance
			minDistance = distance
			closestLayer = layer
	snapPreviewPanelToSnapPoint(closestLayer)

snapPreviewPanelToSnapPoint = (snapPoint) ->
	if viewMode != 1 then return
	panel = sketch.preview
	minRange = 8
	pass = false
	if Math.abs(snapPoint.midX - panel.midX) - panel.width / 2 > minRange + snapPoint.width / 2 then pass = true
	if Math.abs(snapPoint.midY - panel.midY) - panel.height / 2 > minRange + snapPoint.height / 2 then pass = true
	unless pass
		if snapPoint.x > panel.x 
			x = snapPoint.maxX
			if snapPoint.minY > panel.minY 
				y = snapPoint.maxY
				panel.animate maxX: x, maxY: y
			else 
				y = snapPoint.minY
				panel.animate maxX: x, minY: y
		else 
			x = snapPoint.x
			if snapPoint.minY > panel.minY 
				y = snapPoint.maxY
				panel.animate minX: x, maxY: y
			else 
				y = snapPoint.minY
				panel.animate minX: x, minY: y
	area = sketch.nodes
	if  Math.abs(area.maxX - panel.maxX) <= 8
		panel.animate maxX: area.maxX
	else if  Math.abs(area.x - panel.x) <= 8
		panel.animate x: area.x
	else if  Math.abs(area.y - panel.y) <= 8
		panel.animate y: area.y
	else if Math.abs(area.maxY - panel.maxY) <= 8
		panel.animate maxY: area.maxY
	Utils.delay 0.4, ->
		previewDefaultPoint = sketch.preview.point

###############################
# PREVIEW RESIZING

sketch.mirrorIcon.addMouseHoverState()
sketch.viewSize.addMouseHoverState()
viewSizeTextStyle = 
	"opacity": "0.9"
	"font-family": "OpenSans"
	"font-size": "12px"
	"line-height": "17px"
sketch.viewSizeText.style = viewSizeTextStyle
sketch.viewSizeText.html = "iPhone 7"

sketch.Keys_alt.convertToOpacityInvisible()
sketch.Keys_cmd.convertToOpacityInvisible()

Events.wrap(window).addEventListener "keydown", (event) ->
	if event.keyCode == 37 
		sketch.Keys_cmd.animate opacity: 1
		previewAspectRatioIsOn = false
		previewManualResizingIsOn = true
	if event.keyCode == 38 
		sketch.Keys_alt.animate opacity: 1
		snapToDeviceSizes = true

Events.wrap(window).addEventListener "keyup", (event) ->
	if event.keyCode == 37 
		sketch.Keys_cmd.animate opacity: 0
		previewAspectRatioIsOn = true
		previewManualResizingIsOn = false
	if event.keyCode == 38 
		sketch.Keys_alt.animate opacity: 0
		snapToDeviceSizes = false

sketch.previewResizingAreaLeft.makeResizeable (point) -> 
	point.x = Math.round(point.x)
	point.y = sketch.previewResizingAreaLeft.y
	return point
	
sketch.previewResizingAreaLeft.on Events.Drag, (event, draggable, layer) ->
	if snapToDeviceSizes
		document.body.style.cursor = "ew-resize"
		step = defaultDeviceIndex + Math.floor(-event.offset.x / 50)
		nextDevice = Math.min(deviceSizes.length - 1, step)
		if nextDevice < 0 then nextDevice = 0
		if nextDevice != currentDeviceIndex
			currentDeviceIndex = nextDevice
			device = deviceSizes[currentDeviceIndex]
			defaultPreviewFlowRatio = device.width / device.height
			defaultPreviewFlowWidth = device.width
			sketch.preview.width = device.width * previewFlow.scale
			sketch.viewSizeText.html = device.name
			previewManualResizingHappened = false
	else
		sketch.preview.width -= event.deltaX
		if !previewAspectRatioIsOn then previewManualResizingHappened = true
	sketch.previewResizingAreaLeft.height = sketch.previewArea.height

sketch.previewResizingAreaLeft.onDragEnd ->
	if snapToDeviceSizes then document.body.style.cursor = "auto"
	defaultDeviceIndex = currentDeviceIndex
	sketch.previewResizingAreaLeft.x = sketch.preview.x - 8
	sketch.previewResizingAreaTop.x = sketch.preview.x + 157
	sizeText = "#{previewFlow.width.toFixed(0)} / #{previewFlow.height.toFixed(0)} px"
	sketch.viewSizeText.html = sizeText
	if previewAspectRatioIsOn and !previewManualResizingHappened
		device = deviceSizes[currentDeviceIndex]
		sketch.viewSizeText.html = device.name

sketch.preview.on "change:size", ->
	width = this.size.width - 4
	height = sketch.previewAreaFrame.height - 4
	if previewAspectRatioIsOn
		if previewWidthIsChanging
			height = Math.round(width / defaultPreviewFlowRatio)
		else
			width = Math.round(height * defaultPreviewFlowRatio)
	width += 4
	height += 34
	if viewMode == 3
		sketch.previewToolbar.width = sketch.panel.width
	else
		sketch.previewToolbar.width = width
	sketch.previewBG.width = width
	sketch.previewBG.height = height - 30
	sketch.previewAreaFrame.width = width
	sketch.previewAreaFrame.height = height - 30
	sketch.previewArea.width = width - 4
	sketch.previewArea.height = height - 34
	sketch.preview.width = width 
	sketch.preview.height = height
	sizeText = "#{previewFlow.width.toFixed(0)} / #{previewFlow.height.toFixed(0)} px"
	if previewAspectRatioIsOn
		previewFlow.scale = sketch.previewArea.width / defaultPreviewFlowWidth
		if snapToDeviceSizes
			previewFlow.width = sketch.previewArea.width / previewFlow.scale
			previewFlow.height = sketch.previewArea.height / previewFlow.scale
			sketch.preview.x = previewMaxX - sketch.preview.width
		else
			if sketch.previewResizingAreaLeft.draggable.isDragging and viewMode != 3 and !sketch.preview.isAnimating
				sketch.viewSizeText.html = "Scale : #{previewFlow.scale.toFixed(2)}"
			else 
				if viewMode == 1 then sketch.viewSizeText.html = sizeText
				if previewAspectRatioIsOn and !previewManualResizingHappened
					device = deviceSizes[currentDeviceIndex]
					sketch.viewSizeText.html = device.name
				if viewMode == 3 then sketch.viewSizeText.html = "1280 / 370 px"
	else
		previewFlow.width = sketch.previewArea.width / previewFlow.scale
		defaultPreviewFlowWidth = previewFlow.width
		defaultPreviewFlowRatio = previewFlow.width / previewFlow.height
		sketch.viewSizeText.html = sizeText
	if (previewMaxX - sketch.preview.width) <= 20
		sketch.preview.x = 0
	else
		sketch.preview.maxX = previewMaxX
	if viewMode != 3 and viewMode != 2 and !previewSmallModeIsOn
		previewDefaultSize = sketch.preview.size
	if previewSmallModeIsOn and !sketch.preview.isAnimating
		previewSmallDefaultWidth = sketch.preview.width 

sketch.previewToolbar.on "change:size", ->
	dragging = sketch.previewResizingAreaLeft.draggable.isDragging
	iconsCenter = sketch.previewIconsCenter
	iconsRight = sketch.previewIconsRight
	moveAreaWidth = iconsCenter.x - sketch.previewIconsLeft.maxX - 16
	if moveAreaWidth < 16 then moveAreaWidth = 16
	sketch.previewMoveArea.width = moveAreaWidth
	if previewSmallModeIsOn
		if dragging
			if this.width > 176
				iconsCenter.x = Align.center
				iconsRight.animate 
					opacity: 1, options: animationOptionsFastEase3
			else
				iconsCenter.x = Align.right
				iconsRight.animate 
					opacity: 0, options: animationOptionsFastEase3
	else
		if dragging
			if this.width > 176
				iconsCenter.animate 
					opacity: 1, options: animationOptionsFastEase3
			else
				iconsCenter.animate 
					opacity: 0, options: animationOptionsFastEase3
			iconsCenter.x = Align.center
			iconsRight.animate 
				opacity: 1, options: animationOptionsFastEase3
	iconsRight.x = Align.right

sketch.previewIconsCenterDefault2.convertToOpacityInvisible()
sketch.previewIconsCenterHover2.convertToOpacityInvisible()

sketch.previewIconsCenter.addMouseHoverState true, ->
	preview = sketch.preview
	iconsCenter = sketch.previewIconsCenter
	iconsRight = sketch.previewIconsRight
	if previewSmallModeIsOn
		sketch.previewIconsCenterDefault1.opacity = 1
		sketch.previewIconsCenterDefault2.opacity = 0
		sketch.previewIconsCenterHover1.opacity = 1
		sketch.previewIconsCenterHover2.opacity = 0
		if previewDefaultSize.width > 176
			iconsCenter.animate 
				opacity: 1, x: previewDefaultSize.width / 2 - 16
				options: animationOptionsFastEase1
		else
			iconsCenter.animate
				opacity: 0, options: animationOptionsFastEase3
		iconsRight.animate
			opacity: 1, options: animationOptionsFastEase3
		preview.animate 
			width: previewDefaultSize.width, options: animationOptionsFastEase1
	else
		sketch.previewIconsCenterDefault1.opacity = 0
		sketch.previewIconsCenterDefault2.opacity = 1
		sketch.previewIconsCenterHover1.opacity = 0
		sketch.previewIconsCenterHover2.opacity = 1
		if previewSmallDefaultWidth <= 176
			iconsCenter.animate 
				opacity: 1, x: previewSmallDefaultWidth - 32
				options: animationOptionsFastEase1
			iconsRight.animate
				opacity: 0, options: animationOptionsFastEase3
		else
			iconsCenter.animate 
				opacity: 1, x: previewSmallDefaultWidth / 2 - 16 
				options: animationOptionsFastEase1
			iconsRight.animate
				opacity: 1, options: animationOptionsFastEase3
		preview.animate 
			width: previewSmallDefaultWidth, options: animationOptionsFastEase1
	previewSmallModeIsOn = !previewSmallModeIsOn

###############################
# VIEW MODES

adjustComponentListPosition = () ->
	point = activeComponentsListItem.convertPointToLayer(activeComponentsListItem.maxY, sketch.window)
	deltaY = point.y - sketch.preview.y + 30
	if deltaY > 0 then sketch.componentsList.y -= deltaY

sketch.viewMode1.onClick ->
	temp = previewMaxX
	viewMode = 1
	if previewFlow.width < 720 
		sketch.photoOfTheDay_day_desktop.visible = false
	else
		sketch.photoOfTheDay_day_desktop.parent = previewFlow
	previewFlow.visible = true	
	sketch.viewMode1.opacity = .6 
	sketch.viewMode2.opacity = .2
	sketch.viewMode3.opacity = .2
	sketch.preview.size = previewDefaultSize
	sketch.preview.y = previewDefaultPoint.y
	sketch.preview.maxX = temp
	sketch.componentsList.y = 31

sketch.viewMode2.onClick ->
	viewMode = 2
	if previewFlow.width < 720 
		sketch.photoOfTheDay_day_desktop.visible = false
	else
		sketch.photoOfTheDay_day_desktop.parent = previewFlow
	previewFlow.visible = true	
	sketch.viewMode1.opacity = .2
	sketch.viewMode2.opacity = .6
	sketch.viewMode3.opacity = .2
	sketch.preview.size = { width:282, height:528 }
	sketch.preview.props = x: Align.left, y: Align.bottom
	adjustComponentListPosition()

sketch.viewMode3.onClick ->
	viewMode = 3
	sketch.viewMode1.opacity = .2
	sketch.viewMode2.opacity = .2
	sketch.viewMode3.opacity = .6
	sketch.preview.props = 
		x: 0, y: 400
		width: windowFlow.width, height: windowFlow.height - 400
	
	sketch.photoOfTheDay_day_desktop.visible = true
	desktop = sketch.photoOfTheDay_day_desktop
	desktop.parent = sketch.previewArea
	previewFlow.visible = false
	desktop.props = size: sketch.previewArea.size, x: 0, y: 0
	sketch.potdDesktopContainer.centerX()
	adjustComponentListPosition()

###############################
# INSPECTOR LAYERS

sketch.navigationBar1Inspector.convertToScalableInspectorLayer()
sketch.navigationBar2Inspector.convertToScalableInspectorLayer()

# PANEL

componentsList = sketch.componentsList
componentsList.clip = true

sketch.componentsList.on Events.MouseWheel, (event, layer) ->
	sketch.componentsList.y -= event.deltaY

activeNodes = sketch.mainScreen_nodes

componentsListHeightBeeforeAnimation = null
componentsListPreviousHeight = null
componentsListFolderItemTapped = null

sketch.componentsAddMenu.addOpacityToggleState()
sketch.componentsAddMenuItem1.addMouseHoverState()
sketch.componentsAddMenuItem2.addMouseHoverState()

sketch.mediaQueryPopup.addOpacityToggleState()
sketch.mediaQueryPopup.changeMouseOnHover("text")
sketch.addMediaQueryIcon.addMouseHoverState true, ->
	sketch.mediaQueryPopup.animate("default")
	popupOpen = sketch.mediaQueryPopup

cursor = sketch.mediaQueryPopupCursor.visible = false
Utils.interval 0.6, ->
	cursor = sketch.mediaQueryPopupCursor
	cursor.visible = !cursor.visible

sketch.addComponentIcon.addMouseHoverState true, ->
	sketch.componentsAddMenu.animate("default")
	popupOpen = sketch.componentsAddMenu

makeClickableComponentsListFolderItem = (layers) ->
	for layer in layers
		layer.onTap ->
			componentsListFolderItemTapped = this
			componentsListHeightBeeforeAnimation = componentsList.height
			componentsListPreviousHeight = componentsList.height
			opened = sketch["#{this.name}Opened"] 
			closed = sketch["#{this.name}Closed"]
			height = sketch["#{this.name}Folder"].height
			if opened.visible then height = -height
			componentsList.animate
				height: componentsList.height + height
				options: {curve: "ease", time: 0.15 + 0.0005 * Math.abs(height)}
			closed.visible = opened.visible
			opened.visible = !opened.visible

makeClickableComponentsListFolderItem([
	sketch.componentListItem_items
	sketch.componentListItem_customFlowTransitions
	sketch.componentListItem_screens
])

componentsList.on "change:height", ->
	folder = sketch["#{componentsListFolderItemTapped.name}Folder"]
	deltaY = componentsListPreviousHeight - componentsList.height
	componentsListPreviousHeight = componentsList.height
	for layer in this.children
		if layer.maxY > componentsListFolderItemTapped.maxY || layer.id is folder.id
			layer.y -= deltaY 

makeComponentsListItemClickable = (item) ->
	item[0].onTap ->
		sketch["#{activeComponentsListItem.name}Opened"].visible = false
		sketch["#{activeComponentsListItem.name}Closed"].visible = true
		activeComponentsListItem = this
		sketch["#{this.name}Opened"].visible = true
		sketch["#{this.name}Closed"].visible = false
		for nodes in sketch.nodes.children
			nodes.visible = false
		sketch.nodeEditorArea.visible = true
		nodes = sketch["#{this.name.substring(18)}_nodes"]
		nodes.visible = true
		activeNodes = nodes
		item[1]()

clickableComponentsList = [
	[
		sketch.componentListItem_mainScreen, ->
			activeComponentsListItem = sketch.componentListItem_mainScreen
			toggleInstanceSection(false)
	]
	[
		sketch.componentListItem_photoDetailScreen, ->
			activeComponentsListItem = sketch.componentListItem_photoDetailScreen
			sketch.goBack1NodeHoverArea.addNodeSelectionAction()
			toggleInstanceSection(false)
	]
	[
		sketch.componentListItem_menuPanel, ->
			activeComponentsListItem = sketch.componentListItem_menuPanel
			enableShowCaseResponsiveDesign()
			toggleInstanceSection(false)
	]
	[
		sketch.componentListItem_scaleToFullScreen, ->
			activeComponentsListItem = sketch.componentListItem_scaleToFullScreen
			enableShowCaseCustomFlowTransition()
			toggleInstanceSection(false)
	]
	[
		sketch.componentListItem_filterListItem, ->
			activeComponentsListItem = sketch.componentListItem_filterListItem
			enableShowCaseBetterCodingAndDebugging()
			toggleInstanceSection(true)
			sketch.instanceComboboxHTML.html = sketch.filterItemAntarticaPreview.html
			sketch.identifierComboboxHTML.html = "Tag Text"
			sketch.parentComboboxHTML.html = "Filter-Mo…"
	]
	[
		sketch.componentListItem_photoListItem, ->
			activeComponentsListItem = sketch.componentListItem_photoListItem
			sketch.showPhotoDetailNodeHoverArea.addNodeSelectionAction()
			toggleInstanceSection(true)
			sketch.instanceComboboxHTML.html = "07/20/2017"
			sketch.identifierComboboxHTML.html = "Date"
			sketch.parentComboboxHTML.html = "Photo List"
	]
]

for item in clickableComponentsList
	makeComponentsListItemClickable(item)

##############################################################
# RESIZING

sketch.panelSizingArea.makeResizeable (point) ->
	point.y = sketch.panelSizingArea.y
	sketch.panel.width += point.x - sketch.panelSizingArea.x
	alignRight(sketch.componentsToolbarIcons, sketch.panelBorder)
	return point

##############################################################
# CONNECTED PROPERTIES

textFieldStyle =
	"font-family": "OpenSans";
	"font-size": "13px";
	"margin-left": "7px";
	"line-height": "27px";
sketch.progressTextfield1.style = textFieldStyle
sketch.progressTextfield1.opacity = 0.9
sketch.progressTextfield1.html = 0
sketch.progressTextfield2.style = textFieldStyle
sketch.progressTextfield2.html = 1
sketch.progressTextfield2.opacity = 0.6

# NODES

nodeSelected = false

###############################
# NODE

addNodeSelectionAction = (layer) ->
	outerArea = layer.children[0]
	outerArea.onMouseOver (event, outerArea) ->
		if nodeSelected then return
		sketch["#{layer.parent.name}1"].visible = false
		sketch["#{layer.parent.name}2"].visible = true
		sketch["#{layer.parent.name}3"].visible = false
	layer.onMouseOut (event, layer) ->
		if nodeSelected then return
		sketch["#{layer.parent.name}1"].visible = true
		sketch["#{layer.parent.name}2"].visible = false
		sketch["#{layer.parent.name}3"].visible = false
	innerArea = layer.children[1]
	innerArea.onMouseOver (event, innerArea) ->
		if nodeSelected then return
		sketch["#{layer.parent.name}1"].visible = false
		sketch["#{layer.parent.name}2"].visible = false
		sketch["#{layer.parent.name}3"].visible = true
	this.onTap ->
		nodeSelected = layer
		sketch.propertyList.visible = true
		sketch["#{layer.parent.name}1"].visible = false
		sketch["#{layer.parent.name}2"].visible = true
		sketch["#{layer.parent.name}3"].visible = false
		for item in sketch.propertyList.children
			item.visible = false
		sketch["#{layer.parent.name}PL"].visible = true

Layer::addNodeSelectionAction = (onTap, bringToFront = false) ->
	parentName = this.parent.name
	editIcon = sketch["#{parentName}EditIconHighlighted"]
	editIcon?.props = visible: true, opacity: 0
	normal = sketch["#{parentName}Default"]
	highlighted = sketch["#{parentName}Highlighted"]
	bordered = sketch["#{parentName}Bordered"]
	outerArea = this.children[0]
	outerArea.onMouseOver ->
		if nodeSelected then return
		if bringToFront then this.parent.parent.bringToFront()
		normal.visible = false
		highlighted.visible = false
		bordered.visible = true
	this.onMouseOut ->
		if nodeSelected then return
		normal.visible = true
		highlighted.visible = false
		bordered.visible = false
	innerArea = this.children[1]
	innerArea.onMouseOver ->
		if nodeSelected then return
		normal.visible = false
		highlighted.visible = true
		bordered.visible = false
	editIcon?.onMouseOver ->
		normal.visible = false
		bordered.visible = nodeSelected
		highlighted.visible = !nodeSelected
		editIcon.opacity = 1
	editIcon?.onMouseOut ->
		editIcon.opacity = 0
	editIcon?.onMouseDown ->
		editIcon.opacity = 0
	editIcon?.onMouseUp ->
		editIcon.opacity = 1
	this.onTap ->
		normal.visible = false
		highlighted.visible = false
		bordered.visible = true
		nodeSelected = this
		sketch.propertyList.visible = true
		for item in sketch.propertyList.children
			item.visible = false
		sketch.addMediaQueryIcon.visible = true
		sketch["#{parentName}PL"]?.visible = true
		if onTap then onTap()

sketch.showMenu1NodeHoverArea.addNodeSelectionAction()
sketch.filtersMobileNodeHoverArea.addNodeSelectionAction()
sketch.filtersMobileNodePL.addSizeConstraintModes()
sketch.filtersMobileNode.addPreviewInspectionFeature(sketch.filtersMobileInspector)

###############################
# NODE CONNECTION

connectionSelected = null
Layer::addNodeConnectionSelectionAction = (onTap) ->
	hover = sketch["#{this.name}Hover"]
	normal = sketch["#{this.name}Default"]
	focus = sketch["#{this.name}Focus"]
	this.onMouseOver (event, layer) ->
		if focus?.visible then return
		hover.visible = true
		normal.visible = false
	this.onMouseOut (event, layer) ->
		if focus?.visible then return
		hover.visible = false
		normal.visible = true
	this.onTap (event, layer) ->
		if !focus then return 
		focus.visible = true
		hover.visible = false
		normal.visible = false
		connectionSelected = layer
		sketch.propertyList.visible = true
		for item in sketch.propertyList.children
			item.visible = false
		sketch["#{layer.name}PL"].visible = true
		if onTap then onTap()

###############################
# NODE EDITOR AREA

draggingNodes = false

sketch.nodeEditorArea.onPanStart ->
	draggingNodes = true

sketch.nodeEditorArea.on Events.Pan, (event) ->
	activeNodes.x += event.deltaX
	activeNodes.y += event.deltaY

sketch.nodeEditorArea.onPanEnd ->
	Utils.delay 0.1, ->
		draggingNodes = false

unselectNode = () ->
	if !nodeSelected then return 
	sketch["#{nodeSelected.parent.name}Bordered"]?.visible = false
	sketch["#{nodeSelected.parent.name}Default"]?.visible = true
	sketch["#{nodeSelected.parent.name}Highlighted"]?.visible = false
	sketch["#{nodeSelected.parent.name}1"]?.visible = true
	sketch["#{nodeSelected.parent.name}2"]?.visible = false
	sketch["#{nodeSelected.parent.name}3"]?.visible = false
	sketch.propertyList.visible = false
	sketch["#{nodeSelected.parent.name}PL"].visible = false
	nodeSelected = null

unselectNodeConnection = () ->
	if !connectionSelected then return 
	sketch["#{connectionSelected.name}Hover"].visible = false
	sketch["#{connectionSelected.name}Default"].visible = true
	sketch["#{connectionSelected.name}Focus"].visible = false
	sketch.propertyList.visible = false
	sketch["#{connectionSelected.name}PL"].visible = false
	connectionSelected = null

sketch.nodeEditorArea.onTap ->
	if draggingNodes then return
	if popupOpen
		popupOpen.animate("hidden")
		popupOpen = null
		return
	sketch.layerManagementButtonsActive.visible = false
	unselectNode()
	unselectNodeConnection()

# PREVIEW FLOW

previewFlow = new FlowComponent
	parent: sketch.previewArea
	originX: 0, originY: 0
	width: 375, height: 667
	scale: 0.7413
previewFlow.showNext(sketch.photoOfTheDay_day_mobile, animate: false, scroll: false)

photoList = convertToScrollComponent(sketch.photoList)
photoList.width = previewFlow.width
photoList.height = 611
sketch.photoList.width = previewFlow.width

photoList.onMove ->
	sketch.scalePhotoItem.y = photoList.content.y + 480
sketch.compareList.visible = false

###############################
# FLEXBOX

sketch.navigationBar.style =
	"display": "flex"
	"justify-content": "space-between"
	"background": "#F1CB08"
	"box-shadow": "0 0 16px 0 rgba(0,0,0,0.16)"
	"flex-direction": "row-reverse"

for layer in sketch.navigationBar.children
	layer.props = x: 0, y:0
	layer.style =
		"position": "relative"
		"flex": "none"

###############################
# SIZE CHANGE

previewFlow.on "change:size", ->
	if previewManualResizingIsOn or snapToDeviceSizes
		if previewFlow.width >= 720
			sketch.photoOfTheDay_day_desktop.visible = true
			desktop = sketch.photoOfTheDay_day_desktop
			previewFlow.showNext(desktop, animate: false, scroll: false)
			desktop.size = previewFlow.size
			sketch.potdDesktopContainer.centerX()
			return
		else
			previewFlow.showNext(sketch.photoOfTheDay_day_mobile, animate: false, scroll: false)
		
		sketch.photoOfTheDay_day_mobile.size = previewFlow.size
		sketch.navigationBar.width = previewFlow.width
		sketch.navigationBar1Inspector.width = previewFlow.width
		sketch.fullOverlay.width = previewFlow.width
		photoList.width = previewFlow.width 
		photoList.height = previewFlow.height 
		sketch.photoList.width = previewFlow.width
		sketch.bottomGradient.width = previewFlow.width
		
		alignLeft(sketch.selectMonthIcon_mobile)
		alignBottom(sketch.selectMonthIcon_mobile)
		alignLeft(sketch.categories_mobile)
		alignBottom(sketch.categories_mobile)
		alignLeft(sketch.bottomGradient)
		alignBottom(sketch.bottomGradient)
		
		if sketch.photoList.visible then layoutPhotoList()
		 
layoutPhotoList = () ->
	parentWidth = sketch.photoList.width
	itemWidth = (parentWidth - 4) / 3
	if itemWidth < 187
		itemWidth = (parentWidth - 2) / 2
	itemHeight = itemWidth * 9 / 16
	itemX = 0
	itemY = 0
	for layer in sketch.photoList.children
		if layer.name is "headerPhoto"
			layer.width = parentWidth
			layer.height = parentWidth * 9 / 16
			itemY = layer.height + 2
		else
			layer.width = itemWidth
			layer.height = itemHeight
			layer.x = itemX
			layer.y = itemY
			if itemX + itemWidth >= parentWidth
				itemX = 0
				itemY += itemHeight + 2
			else
				itemX += itemWidth + 2
		alignLeft(layer.children[0])
		alignBottom(layer.children[0])
	photoList.updateContent()
	
layoutPhotoList()

###############################
# MONTH LIST

monthList = convertToScrollComponent(sketch.selectAMonth)
monthList.props = height: 677 - 285, clip: false

sketch.selectAMonthOverlay.props = opacity: 0, visible: true
sketch.navigationBar_selectAMonth.props = opacity: 0, visible: true

sketch.selectMonthIcon_mobile.onTap ->
	sketch.selectAMonthOverlay.ignoreEvents = false
	photoList.ignoreEvents = true
	sketch.cancelIcon.visible = true
	sketch.categories_mobile.animate opacity: 0
	sketch.selectAMonthOverlay.animate opacity: 1
	sketch.navigationBar_selectAMonth.animate opacity: 1
	monthList.animate y: 285

sketch.selectAMonthOverlay.onTap ->
	closeMonthList()

sketch.cancelIcon.onTap ->
	closeMonthList()
	
closeMonthList = () ->
	sketch.selectAMonthOverlay.ignoreEvents = true
	photoList.ignoreEvents = false
	sketch.cancelIcon.visible = false
	sketch.categories_mobile.animate opacity: 1
	sketch.selectAMonthOverlay.animate opacity: 0
	sketch.navigationBar_selectAMonth.animate opacity: 0
	monthList.animate y: 700

###############################
# CATEGORIES

toggleCategoriesInPreview = null
sketch.itemAmericaActive.props = visible: true, opacity: 0
sketch.categories_mobile.onTap ->
	toggleCategories()
	toggleCategoriesInPreview?()
toggleCategories = () ->
	opacity = sketch.itemAllActive.opacity
	sketch.itemAllActive.animate 
		opacity: 1 - opacity, options: curve: "ease-out", time: 0.3
	sketch.itemAmericaActive.animate 
		opacity: opacity, options: curve: "ease-out", time: 0.3

###############################
# PHOTO DETAIL SCREEN

scaleToScreen = (nav, layerA, layerB, overlay) ->
	options = animationOptionsSpring1
	transition =
		layerA:
			show: {options: options}
			hide: {options: options}
		layerB:
			show:
				options: options, originX: 0, originY: 0, 
				opacity: 1, x: 0, y: 0, scaleX: 1, scaleY: 1
			hide: 
				options: options, opacity: 0
				x: sketch.scalePhotoItem.x, y: sketch.scalePhotoItem.y
				scaleX: 0.5, scaleY: 0.16
		overlay:
			show: {options: options, opacity: 0.8, size: nav.size, x: 0, y: 0}
			hide: {options: options, opacity: 0, size: nav.size, x: 0, y: 0}

openPhotoDetailScreen = () ->
	photoListItemTapPathAnimation.play()
	componentInputsDatePathAnimation.play()
	componentInputsNamePathAnimation.play()
	componentInputsImagePathAnimation.play()
	goBackTransitionProgressPathAnimation.play()
	animateButtonTap(sketch.connectedShowNextButton1)
	sketch.photoDetail_mobile.props = 
		originX: 0, originY: 0
		scaleX: 0.5, scaleY: 0.16
		x: sketch.scalePhotoItem.x, y: sketch.scalePhotoItem.y
		opacity: 0
	previewFlow.transition(sketch.photoDetail_mobile, scaleToScreen)
sketch.photo.onTap ->
	if sketch.photoDetail_mobile.x != 0
		openPhotoDetailScreen()
	else 
		this.animate
			height: if this.height == 400 then 667 else 400
			y: if this.height == 400 then 0 else (667-400)/2

sketch.photo.props = 
	style: "background-size": "cover"
	image: "images/photoDetail.jpg"
sketch.photo.on "change:height", ->
	photoTapPathAnimation.play()
	photoStateOpacityProgressPathAnimation.play()
	photoStateHeightPathAnimation.play()
	progress = Utils.modulate(sketch.photo.height, [400, 667], [0, 1])
	changePhotoDetailScreenElementsOpacity(progress)

sketch.scalePhotoItem.onTap ->
	openPhotoDetailScreen()

changePhotoDetailScreenElementsOpacity = (opacity) ->
	sketch.closeIcon.opacity = opacity
	sketch.bookmarkIcon.opacity = opacity
	sketch.other.opacity = opacity

sketch.photoDetail_mobile.on "change:scaleX", ->
	progress = Utils.modulate(sketch.photoDetail_mobile.scaleX, [0.5, 1], [0, 1])
	changePhotoDetailScreenElementsOpacity(progress)
	sketch.progressTextfield2.html = parseFloat(progress).toFixed(2)
	if progress > 0.98 
		sketch.progressTextfield2.html = 1
	if progress < 0.02
		sketch.progressTextfield2.html = 0

sketch.fullOverlay.props = visible: true, opacity: 0
sketch.closeIcon.onTap ->
	goBackShowPreviousPathAnimation.play()
	goBackTransitionProgressPathAnimation.play()
	animateButtonTap(sketch.connectedShowPreviousButton1)
	previewFlow.showPrevious()
sketch.connectedShowPreviousButton1.onTap ->
	animateButtonTap(sketch.connectedShowPreviousButton1)
	previewFlow.showPrevious()

###############################
# MENU PANEL

sketch.menuIcon.onTap ->
	showMenuShowNextPathAnimation?.play()
	sketch.showMenuNextButton.animateButtonTap()
	sketch.menuPanel.animate x: -16
	sketch.fullOverlay.ignoreEvents = false

photoList.on Events.SwipeRight, (event) ->
	if !(event.deltaX == 0 or sketch.menuPanel.x >= -15)
		showMenuPathAnimation1.play()
	panelWidth = sketch.menuPanel.width - 16
	if sketch.menuPanel.x <= -16
		sketch.menuPanel.x += event.deltaX

photoList.on Events.SwipeRightEnd, (event) ->
	showMenuPathAnimation1.play()
	panelWidth = sketch.menuPanel.width - 16
	progress = Utils.modulate(sketch.menuPanel.x, [-panelWidth, -16], [0, 1])
	if progress > 0.5
		sketch.menuPanel.animate x: -16
		sketch.fullOverlay.ignoreEvents = false
	else 
		sketch.menuPanel.animate x: -panelWidth

sketch.menuPanel.on "change:x", ->
	panelWidth = sketch.menuPanel.width - 16
	progress = Utils.modulate(sketch.menuPanel.x, [-panelWidth, -16], [0, 1])
	sketch.fullOverlay.opacity = progress
	sketch.progressTextfield1.html = parseFloat(progress).toFixed(2)
	if progress > 0.98 
		sketch.progressTextfield1.html = 1
	if progress < 0.02
		sketch.progressTextfield1.html = 0

sketch.fullOverlay.onTap ->
	sketch.showMenuPreviousButton.animateButtonTap()
	sketch.fullOverlay.ignoreEvents = true
	sketch.menuPanel.animate x: -sketch.menuPanel.width + 16
sketch.fullOverlay.ignoreEvents = true

beforeViewMode3 = {
	size: sketch.preview.size, scale: previewFlow.scale
}
 
sketch.potdDesktopMenu.addOpacityToggleState()
sketch.potdDesktopRightItems.onTap ->
	if sketch.potdDesktopMenu.opacity != 1
		sketch.potdDesktopMenu.animate("default")
		sketch.showMenuNextButton.animateButtonTap()
		showMenuShowNextPathAnimation?.play()
	else
		sketch.potdDesktopMenu.animate("hidden")
		sketch.showMenuPreviousButton.animateButtonTap()

sketch.photoOfTheDay_day_desktop.onTap ->
	if sketch.potdDesktopMenu.opacity == 1
		sketch.potdDesktopMenu.animate("hidden")
		sketch.showMenuPreviousButton.animateButtonTap()

# PATH ANIMATIONS

pathDebugging = false
# pathDebugging = true

generatePathAnimation = (parent, time, direction, svg, x = 7, y = 3) ->
	if direction == "-" then direction = "+" else direction = "-"
	if time < 1 then time = 1
	isRotationPath = parent.id == sketch.animationRotationZPath.id
	path = new Layer
		parent: parent, x: x, y: y, opacity: if pathDebugging then 1 else 0
		backgroundColor: null, html: """#{svg}"""
		style: unless pathDebugging then "mix-blend-mode": "overlay"
	Utils.insertCSS("""
		.pathAnimation#{parent.id} {
			stroke: #ffffff !important;
			stroke-dasharray: 5 15;
			animation: dash#{parent.id} #{time + 0.6}s linear infinite;
		}
		@keyframes dash#{parent.id} {
			to {
				stroke-dashoffset: #{direction}#{(time)*59};
			}
		}
	""")
	if pathDebugging then path.classList.add("pathAnimation#{parent.id}")
	path.states.default = opacity: if pathDebugging then 1 else 0
	path.states.animating = opacity: 1
	path.states.animationOptions = {time: 0.3, curve: "linear"}
	animation = {}
	animation.play = () -> 
		if !debugEnabled then return
		if path.opacity == 1 then return
		path.animate("animating")
		path.classList.add("pathAnimation#{parent.id}")
		Utils.delay time - 0.3, ->
			if path.opacity < 1 then return
			path.animate("default")
			Utils.delay 0.3, ->
				path.classList.remove("pathAnimation#{parent.id}")
	return animation

svg = """
<svg width="31px" height="80px" viewBox="302 440 31 80" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
    <path d="M303,441 C317.756402,441 328.312969,453.784277 331.77362,469.001482 M331.738393,491.036983 C328.256665,506.237261 317.784451,519 303,519" id="Path" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" fill="none"></path>
</svg>
"""
showMenuPathAnimation1 = generatePathAnimation(
	sketch.showMenuTransitionProgressPath, 1, "+", svg
)
svg = """
<svg width="90px" height="230px" viewBox="-1 -1 90 230" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
    <path d="M88,0 C52.8,0 35.2,228 4.26325641e-14,228" id="Path" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" fill="none" transform="translate(44.000000, 114.000000) scale(1, -1) translate(-44.000000, -114.000000) "></path>
</svg>
"""
goBackShowPreviousPathAnimation = generatePathAnimation(
	sketch.goBackShowPreviousPath, 1, "+", svg, -.5, 0
)
svg = """
<svg width="58px" height="4px" viewBox="7 2 58 4" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
    <path d="M64,4 L8,4" id="Path" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" fill="none"></path>
</svg>
"""
photoListItemTapPathAnimation = generatePathAnimation(
	sketch.photoListItemTapPath, 1, "-", svg, 6, -18
)
svg = """
<svg width="58px" height="104px" viewBox="888 271 58 104" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
    <path d="M945,272 C922.6,272 911.4,374 889,374" id="Path" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" fill="none"></path>
</svg>
"""
goBackTransitionProgressPathAnimation = generatePathAnimation(
	sketch.goBackTransitionProgressPath, 1, "-", svg
)
svg = """
<svg width="240px" height="134px" viewBox="-1 -1 240 134" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
    <path d="M238,0 C142.8,0 95.2,132 1.13686838e-13,132" id="Path" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" fill="none"></path>
</svg>
"""
componentInputsDatePathAnimation = generatePathAnimation(
	sketch.componentInputsDatePath, 1, "-", svg, -2, 0
)
componentInputsNamePathAnimation = generatePathAnimation(
	sketch.componentInputsNamePath, 1, "-", svg, -2, 0
)
componentInputsImagePathAnimation = generatePathAnimation(
	sketch.componentInputsImagePath, 1, "-", svg, -2, 0
)
svg = """
<svg width="58px" height="158px" viewBox="80 508 58 158" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
    <path d="M137,509 C114.6,509 103.4,665 81,665" id="Path" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" fill="none" transform="translate(109.000000, 587.000000) scale(-1, 1) translate(-109.000000, -587.000000) "></path>
</svg>
"""
photoStateHeightPathAnimation = generatePathAnimation(
	sketch.photoStateHeightPath, 1, "+", svg
)
svg = """
<svg width="58px" height="313px" viewBox="52 275 58 313" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
    <path d="M109,276 C86.6,276 75.4,587 53,587" id="Path" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" fill="none"></path>
</svg>
"""
photoStateOpacityProgressPathAnimation = generatePathAnimation(
	sketch.photoStateOpacityProgressPath, 1, "-", svg
)
svg = """
<svg width="58px" height="158px" viewBox="41 535 58 158" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
    <path d="M98,536 C75.6,536 64.4,692 42,692" id="Path" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" fill="none" transform="translate(70.000000, 614.000000) scale(-1, 1) translate(-70.000000, -614.000000) "></path>
</svg>
"""
photoTapPathAnimation = generatePathAnimation(
	sketch.photoTapPath, 1, "-", svg
)

# DEBUG PANEL

debugEnabled = true
debugPanel = sketch.debugPanel
debugPanel.clip = true
debugPanel.makeMoveable()
debugPanel.addOpacityToggleState()

sketch.debugPanelBG.height = 94 - 31
sketch.instanceSelector.props = opacity: 0, y: -20
sketch.rewind.y = 9

sketch.debugPanelBG.image = null
sketch.debugPanelBG.style =
	"background": "#242424"
	"border": "1px solid #000000"
	"border-radius": "2px"

###############################
# APP BAR

sketch.debugIcon.addMouseHoverState true, ->
	if debugPanel.opacity == 0
		debugPanel.animate("default")
	else 
		debugPanel.animate("hidden")

sketch.debugToggleHandleOff.convertToOpacityInvisible()
sketch.debugToggleHandle.animationOptions = animationOptionsFastEase1
sketch.debugToggleHandleOn.animationOptions = animationOptionsFastEase1
sketch.debugToggleHandleOff.animationOptions = animationOptionsFastEase1

sketch.debugToggle.onTap ->
	handle = sketch.debugToggleHandle
	if handle.x == 19
		handle.animate x: 9
		sketch.debugToggleHandleOn.animate opacity: 0
		sketch.debugToggleHandleOff.animate opacity: 1
		debugEnabled = false
	else
		handle.animate x: 19
		sketch.debugToggleHandleOn.animate opacity: 1
		sketch.debugToggleHandleOff.animate opacity: 0
		debugEnabled = true

toggleInstanceSection = (turnOn = sketch.debugPanelBG.height != 94) ->
	if !turnOn
		sketch.debugPanelBG.animate height: 94 - 31
		sketch.instanceSelector.animate opacity: 0, y: -20
		sketch.rewind.animate y: 9
	else
		sketch.debugPanelBG.animate height: 94
		sketch.instanceSelector.animate opacity: 1, y: 9
		sketch.rewind.animate y: 40

sketch.mirrorIcon.onTap ->
	toggleInstanceSection()

###############################
# INSTANCE SECTION

sketch.instanceCombobox.addMouseHoverState(false)

comboboxStyle =
	"font-family": "OpenSans";
	"font-size": "13px";
	"margin-left": "0px";
	"margin-top": "0px";
	"line-height": "21px";
	"color": "rgba(255,255,255,0.6)"

sketch.instanceComboboxHTML.style = comboboxStyle
sketch.identifierComboboxHTML.style = comboboxStyle
sketch.parentComboboxHTML.style = comboboxStyle

###############################
# REWIND SECTION

rewindHandle = sketch.rewindSliderHandle
rewindHandle.props =
	image: null, backgroundColor: "#999999", borderRadius: 10
rewindHandleColor = null
rewindHandle.onMouseOver ->
	rewindHandleColor = this.backgroundColor
	this.backgroundColor = rewindHandleColor.lighten(20)
rewindHandle.onMouseOut ->
	this.backgroundColor = rewindHandleColor

sketch.rewindToggleHandle.x = 4
sketch.rewindToggleHandleActive.opacity = 0
sketch.rewindInputs.opacity = 0.4
rewindHandle.backgroundColor = "#535353"

sketch.rewindToggle.onTap ->
	handle = sketch.rewindToggleHandle
	active = sketch.rewindToggleHandleActive
	if handle.x == 17
		handle.animate x: 4
		active.animate opacity: 0
		sketch.rewindInputs.animate opacity: .4
		rewindHandle.animate backgroundColor: "#535353"
	else 
		handle.animate x: 17
		active.animate opacity: 1
		sketch.rewindInputs.animate opacity: 1
		rewindHandle.animate backgroundColor: "#999999"

rewindHandle.draggable.enabled = true
rewindHandle.draggable.momentum = false
rewindHandle.draggable.vertical = false
rewindHandle.draggable.overdrag = false
rewindHandle.draggable.constraints = x: 0, width: 300
rewindHandle.onDragStart ->
	sketch.debugPanel.draggable = false
rewindHandle.onDragEnd ->
	sketch.debugPanel.draggable = true

sketch.rewindTime.visible = false
rewindTimeStyle = 
	"opacity": "0.4"
	"font-family": "OpenSans-Semibold"
	"font-size": "10px"
	"text-align": "center"
	"line-height": "14px"
sketch.rewindTime.style = rewindTimeStyle

sketch.playRewind.addMouseHoverState true, ->
	time = Utils.modulate(rewindHandle.x, [0, 285], [3, 0])
	rewindHandle.animate
		x: 285, options: curve: "linear", time: time
	sketch.rotationZConnection.index = 5

# RESPONSIVE COMPONENTS

desktopModeIsActive = false
sketch.showMenuPositionXField.opacity = 0
	
showRelatedNodes = () ->
	if previewFlow.width >= 720 or viewMode == 3
		if desktopModeIsActive == true then return
		desktopModeIsActive = true
	else 
		if desktopModeIsActive == false then return
		desktopModeIsActive = false

	sketch.mainScreenOtherNodes320.visible = !desktopModeIsActive
	sketch.showMenu1NodeDefault320.visible = !desktopModeIsActive
	sketch.showMenu1NodeHighlighted320.visible = !desktopModeIsActive
	sketch.showMenu1NodeBordered320.visible = !desktopModeIsActive
	
	sketch.menuPanel_nodesOthers320.visible = !desktopModeIsActive
	sketch.showMenu2NodeDefault320.visible = !desktopModeIsActive
	sketch.showMenu2NodeHighlighted320.visible = !desktopModeIsActive
	sketch.showMenu2NodeBordered320.visible = !desktopModeIsActive
	sketch.otherItemsNodeDefault320.visible = !desktopModeIsActive
	sketch.otherItemsNodeHighlighted320.visible = !desktopModeIsActive
	sketch.otherItemsNodeBordered320.visible = !desktopModeIsActive
	
	sketch.filtersMobileNodeDefault320.visible = !desktopModeIsActive
	sketch.filtersMobileNodeHighlighted320.visible = !desktopModeIsActive
	sketch.filtersMobileNodeBordered320.visible = !desktopModeIsActive
	
	
	sketch.mainScreenOtherNodes720.visible = desktopModeIsActive
	sketch.showMenu1NodeDefault720.visible = desktopModeIsActive
	sketch.showMenu1NodeHighlighted720.visible = desktopModeIsActive
	sketch.showMenu1NodeBordered720.visible = desktopModeIsActive
	
	sketch.menuPanel_nodesOthers720.visible = desktopModeIsActive
	sketch.showMenu2NodeDefault720.visible = desktopModeIsActive
	sketch.showMenu2NodeHighlighted720.visible = desktopModeIsActive
	sketch.showMenu2NodeBordered720.visible = desktopModeIsActive
	sketch.otherItemsNodeDefault720.visible = desktopModeIsActive
	sketch.otherItemsNodeHighlighted720.visible = desktopModeIsActive
	sketch.otherItemsNodeBordered720.visible = desktopModeIsActive

	sketch.filtersMobileNodeDefault720.visible = desktopModeIsActive
	sketch.filtersMobileNodeHighlighted720.visible = desktopModeIsActive
	sketch.filtersMobileNodeBordered720.visible = desktopModeIsActive

previewFlow.on "change:size", ->
	showRelatedNodes()
	navigationBarWidthPathAnimation?.play()
	desktopModeIsOn = previewFlow.width >= 720
	sketch.navigationBarWidthPath.visible = desktopModeIsActive
	if desktopModeIsActive
		s = previewFlow.width
		sketch.showMenuPositionXField.html = (( s - 720 ) / 2 + 538).toFixed(0)

sketch.viewMode3.on "change:opacity", ->
	showRelatedNodes()

##############################################################
# SHOW CASES

# BETTER CODING AND DEBUGGING

showCaseBetterCodingAndDebuggingIsEnabled = false

enableShowCaseBetterCodingAndDebugging = ->
	if showCaseBetterCodingAndDebuggingIsEnabled == false
		showCaseBetterCodingAndDebuggingIsEnabled = true
	else
		return
	
	Utils.interval 0.6, ->
		cursors = [
			sketch.popupCodeEditorSCSS1Cursor
			sketch.popupCodeEditorSCSS2Cursor
			sketch.popupCodeEditorCoffeescriptCursor
		]
		for cursor in cursors
			cursor.visible = !cursor.visible
	
	###############################
	# CODE PANELS
	
	sketch.defaultCSSNodeHoverArea.addNodeSelectionAction()
	sketch.popupCodeEditorSCSS1.addOpacityToggleState()
	sketch.popupCodeEditorSCSS1.changeMouseOnHover("text")
	sketch.defaultCSSEditIconHighlighted.onTap ->
		popupOpen = sketch.popupCodeEditorSCSS1
		sketch.popupCodeEditorSCSS1.animate("default")
	
	sketch.selectedCSSNodeHoverArea.addNodeSelectionAction()
	sketch.popupCodeEditorSCSS2.addOpacityToggleState()
	sketch.popupCodeEditorSCSS2.changeMouseOnHover("text")
	sketch.selectedCSSEditIconHighlighted.onTap ->
		popupOpen = sketch.popupCodeEditorSCSS2
		sketch.popupCodeEditorSCSS2.animate("default")
	
	sketch.makeUppercaseJavascriptNodeHoverArea.addNodeSelectionAction()
	sketch.popupCodeEditorCoffeescript.addOpacityToggleState()
	sketch.popupCodeEditorCoffeescript.changeMouseOnHover("text")
	sketch.makeUppercaseJavascriptEditIconHighlighted.onTap ->
		popupOpen = sketch.popupCodeEditorCoffeescript
		sketch.popupCodeEditorCoffeescript.animate("default")
	
	###############################
	# DEBUG PANEL
	
	
	
	sketch.instanceComboboxHTML.html = "AMERICA"
	
	filterItemDefaultStyle =
		"text-align": "center"
		"font-family": "OpenSans-Semibold"
		"font-size": "12px"
		"line-height": "29px"
	sketch.filterItemAntarticaPreview.props = 
		html: "AMERICA"
		style: filterItemDefaultStyle
		image: null
		shadowColor: "rgba(0,0,0,0)"
		color: "rgba(255,255,255,0.9)"
		backgroundColor: "rgba(0,0,0,0.5)"
		shadowBlur: 16
		borderRadius: 20
	
	toggleCategoriesInPreview = () ->
		layer = sketch.filterItemAntarticaPreview
		if layer.backgroundColor.toHexString() == "#f1cb08"
			layer.animate
				backgroundColor: "rgba(0,0,0,0.5)" 
				shadowColor: "rgba(0,0,0,0)"
				color: "rgba(255,255,255,0.9)"
				options: curve: "ease-out", time: 0.3
		else
			layer.animate
				backgroundColor: "#F1CB08"
				shadowColor: "rgba(0,0,0,0.08)"
				color: "rgba(0,0,0,0.8)"
				options: curve: "ease-out", time: 0.3
		tagChangedEventReceivedPathAnimation.play()
		expressionResultPathAnimation.play()
		changeStyleCSSPathAnimation.play()
		tagItemTapPathAnimation.play()
	
	sketch.filterItemAntarticaPreview.onTap ->
		toggleCategories()
		toggleCategoriesInPreview()
	
	sketch.instanceComboboxPanel.addOpacityToggleState()
	sketch.instanceComboboxPanel.addShadow()
	sketch.instanceComboboxPanel.visible = false
	
	sketch.instanceCombobox.onTap ->
		sketch.instanceComboboxPanel.visible = true
		sketch.instanceComboboxPanel.ignoreEvents = 
			!sketch.instanceComboboxPanel.ignoreEvents
		sketch.instanceComboboxPanel.stateCycle("default", "hidden")
	
	changeFilterItemPreview = (html, width) ->
		sketch.filterItemAntarticaPreview.props = 
			html: html, width: width
		sketch.filterItemAntarticaPreview.x = Align.center
		sketch.instanceComboboxHTML.html = "ALL"
		sketch.filterItemAntarticaPreview.props =
			backgroundColor: "rgba(0,0,0,0.5)"
			shadowColor: "rgba(0,0,0,0)"
			color: "rgba(255,255,255,0.9)"
		sketch.instanceComboboxPanel.animate("hidden")
	
	sketch.instanceComboboxPanelAll.addMouseHoverState false, ->
		changeFilterItemPreview("ALL", 53)
		sketch.instanceComboboxHTML.html = "ALL"
	
	sketch.instanceComboboxPanelAmerica.addMouseHoverState false, ->
		changeFilterItemPreview("AMERICA", 85)
		sketch.instanceComboboxHTML.html = "AMERICA"
	
	svg = """
	<svg width="58px" height="4px" viewBox="563 165 58 4" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
	    <path d="M601,167 L564,167" id="Path" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" fill="none"></path>
	</svg>
	"""
	tagChangedEventReceivedPathAnimation = generatePathAnimation(
		sketch.tagChangedEventReceivedPath, 1, "-", svg, 8, -18
	)
	svg = """
	<svg width="42px" height="161px" viewBox="599 127 42 161" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
	    <path d="M640,128 C624,128 616,287 600,287" id="Path" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" fill="none"></path>
	</svg>
	"""
	expressionResultPathAnimation = generatePathAnimation(
		sketch.expressionResultPath, 1, "-", svg
	)
	svg = """
	<svg width="42px" height="108px" viewBox="624 140 42 108" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
	    <path d="M665,141 C649,141 641,247 625,247" id="Path" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" fill="none" transform="translate(645.000000, 194.000000) scale(1, -1) translate(-645.000000, -194.000000) "></path>
	</svg>
	"""
	changeStyleCSSPathAnimation = generatePathAnimation(
		sketch.changeStyleCSSPath, 1, "-", svg
	)
	svg = """
	<svg width="56px" height="4px" viewBox="7 2 58 4" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
	    <path d="M64,4 L8,4" id="Path" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" fill="none"></path>
	</svg>
	"""
	tagItemTapPathAnimation = generatePathAnimation(
		sketch.tagItemTapPath, 1, "-", svg, 8, -18
	)

# CUSTOM FLOW TRANSITION

showCaseBetterCustomFlowTransitionIsEnabled = false

enableShowCaseCustomFlowTransition = () ->
	if showCaseBetterCustomFlowTransitionIsEnabled == false
		showCaseBetterCustomFlowTransitionIsEnabled = true
	else
		return
	
	stfsn = sketch.scaleToFullScreen_nodes
# 	stfsn.makeMoveable()
	sketch.componentInputsNodeHoverArea.addNodeSelectionAction()
	
	###############################
	# VIDEOS
	
	videoNodesDefault = new VideoLayer
		video: "videos/nodesDefault.mov"
		parent: stfsn, width: 758, height: 454
		backgroundColor: "transparent", x: 3, y: 2, visible: false
# 	videoNodesDefault.placeBehind(sketch.rotationZConnection)
	videoNodesRotation = new VideoLayer
		video: "videos/nodesRotation.mov"
		parent: stfsn, width: 758, height: 454
		backgroundColor: "transparent", x: 3, y: 2, visible: false
# 	videoNodesRotation.placeBehind(sketch.rotationZConnection)
	
	previewArea = sketch.previewArea
	videoPreviewDefault = new VideoLayer
		video: "videos/previewDefault.mov" 
		parent: previewArea, width: 278, height: 494
		backgroundColor: "transparent", x: 0, y: 0, visible: false
	videoPreviewRotation = new VideoLayer
		video: "videos/previewRotation.mov" 
		parent: previewArea, width: 278, height: 494
		backgroundColor: "transparent", x: 0, y: 0, visible: false
	
	###############################
	# PANEL
	
	sketch.customTransitionShowPrevious.addTapState ->
		playCustomTransition()
	
	sketch.customTransitionShowNext.addTapState ->
		playCustomTransition()
	
	sketch.rotationZExistProperty.addTapToggleState ->
		visible = !sketch.rotationZConnectionDefaultA.visible
		sketch.rotationZConnectionDefaultA.visible = visible
		sketch.rotationZConnectionHoverA.visible = visible
		sketch.rotationZConnectionFocusA.visible = visible
		sketch.rotationZConnectionDefaultD.visible = !visible
		sketch.rotationZConnectionHoverD.visible = !visible
		sketch.rotationZConnectionFocusD.visible = !visible
		if rewindHandle.x < 283
			if visible
				videoNodesDefault.visible = false
				videoNodesRotation.visible = true
				videoPreviewDefault.visible = false
				videoPreviewRotation.visible = true
			else
				videoNodesDefault.visible = true
				videoNodesRotation.visible = false
				videoPreviewDefault.visible = true
				videoPreviewRotation.visible = false 
	
	###############################
	# NODES
	
	sketch.rotationZConnection.addNodeConnectionSelectionAction ->
		sketch.deleteConnectionIcon.opacity = 1
		sketch.deleteConnectionIcon.animate
			opacity: 0, options: delay: 1.5
	
	svg = """
	<svg width="438px" height="3px" viewBox="157 43 438 3" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
	    <path d="M594,44 L352,44 M198.18457,44 L158,44" id="Path" stroke-width="1.5" stroke-linejoin="round" fill="none"></path>
	</svg>
	"""
	componentInputsShowNextPathAnimation = generatePathAnimation(
		sketch.componentInputsShowNextPath, 1, "-", svg, 8, -18
	)
	componentInputsShowPreviousPathAnimation = generatePathAnimation(
		sketch.componentInputsShowPreviousPath, 1, "-", svg, 8, -18
	)
	svg = """
	<svg width="240px" height="40px" viewBox="755 292 240 40" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
	    <path d="M756,293 C825.151917,293 869.188353,313.050174 924.59636,324.022204 M951.028274,328.32535 C964.370795,330.000361 978.559308,331 994,331" id="Path" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" fill="none"></path>
	</svg>
	"""
	animationTransitionProgressPathAnimation = generatePathAnimation(
		sketch.animationTransitionProgressPath, 1, "+", svg, 6, 3
	)
	svg = """
	<svg width="58px" height="4px" viewBox="563 165 58 4" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
	    <path d="M601,167 L564,167" id="Path" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" fill="none"></path>
	</svg>
	"""
	componentInputsDurationPathAnimation = generatePathAnimation(
		sketch.componentInputsDurationPath, 1, "-", svg, 8, -18
	)
	componentInputsStartXPathAnimation = generatePathAnimation(
		sketch.componentInputsStartXPath, 1, "-", svg, 8, -18
	)
	componentInputsStartYPathAnimation = generatePathAnimation(
		sketch.componentInputsStartYPath, 1, "-", svg, 8, -18
	)
	componentInputsStartWidthPathAnimation = generatePathAnimation(
		sketch.componentInputsStartWidthPath, 1, "-", svg, 8, -18
	)
	componentInputsStartHeightPathAnimation = generatePathAnimation(
		sketch.componentInputsStartHeightPath, 1, "-", svg, 8, -18
	)
	svg = """
	<svg width="42px" height="44px" viewBox="181 218 42 44" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
	    <path d="M222,219 C206,219 198,261 182,261" id="Path" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" fill="none"></path>
	</svg>
	"""
	flowContainerWidthPathAnimation = generatePathAnimation(
		sketch.flowContainerWidthPath, 1, "+", svg, 7, 3
	)
	flowContainerHeightPathAnimation = generatePathAnimation(
		sketch.flowContainerHeightPath, 1, "+", svg, 7, 3
	)
	svg = """
	<svg width="58px" height="4px" viewBox="7 2 58 4" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
	    <path d="M63,4 L8,4" id="Path" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" fill="none"></path>
	</svg>
	"""
	animationXPathAnimation = generatePathAnimation(
		sketch.animationXPath, 1, "-", svg, 7, -18
	)
	animationYPathAnimation = generatePathAnimation(
		sketch.animationYPath, 1, "-", svg, 7, -18
	)
	animationWidthPathAnimation = generatePathAnimation(
		sketch.animationWidthPath, 1, "-", svg, 7, -18
	)
	animationHeightPathAnimation = generatePathAnimation(
		sketch.animationHeightPath, 1, "-", svg, 7, -18
	)
	animationRotationZPathAnimation = generatePathAnimation(
		sketch.animationRotationZPath, 1, "-", svg, 7, -18
	)
	svg = """
	<svg width="58px" height="61px" viewBox="101 425 58 61" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
	    <path d="M158,426 C135.6,426 124.4,485 102,485" id="Path" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" fill="none" transform="translate(130.000000, 455.500000) scale(1, -1) translate(-130.000000, -455.500000) "></path>
	</svg>
	"""
	animationOverlayOpacityPathAnimation = generatePathAnimation(
		sketch.animationOverlayOpacityPath, 1, "-", svg, 7, 3
	)
	svg = """
	<svg width="240px" height="268px" viewBox="166 560 240 268" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
	    <path d="M405,561 C309.8,561 262.2,827 167,827" id="Path" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" fill="none"></path>
	</svg>
	"""
	animationHasReachedEndPathAnimation = generatePathAnimation(
		sketch.animationHasReachedEndPath, 1, "-", svg, 7, 3
	)
	animationHasReachedStartPathAnimation = generatePathAnimation(
		sketch.animationHasReachedStartPath, 1, "-", svg, 7, 3
	)
	
	###############################
	# PREVIEW
	
	previewFlow.showNext(sketch.customTransitionScreen, animate: false, scroll: false)
	sketch.customTransitionScreenOverlay.opacity = 0
	
	stfsn.on "change:visible", ->
		if stfsn.visible
			previewFlow.showNext(sketch.customTransitionScreen, animate: false, scroll: false)
		else
			previewFlow.showPrevious(animate: false)
	
	playCustomTransition = () ->
		target = sketch.customTransitionScreenTarget
		overlay = sketch.customTransitionScreenOverlay
		addRotation = sketch.rotationZConnectionDefaultA.visible
		rotation = if addRotation then 180 else 0
		if target.y == 400
			target.animate 
				x: 0, y: 0, width: 375, height: 667, rotationZ: rotation
			overlay.animate opacity: 1
			componentInputsShowNextPathAnimation.play()
		else 
			if addRotation then target.rotationZ = 180
			target.animate 
				x: 0, y: 400, width: 186, height: 104, rotationZ: 0
			overlay.animate opacity: 0
			componentInputsShowPreviousPathAnimation.play()
		animationTransitionProgressPathAnimation.play()
		componentInputsDurationPathAnimation.play()
		componentInputsStartXPathAnimation.play()
		componentInputsStartYPathAnimation.play()
		componentInputsStartWidthPathAnimation.play()
		componentInputsStartHeightPathAnimation.play()
		flowContainerWidthPathAnimation.play()
		flowContainerHeightPathAnimation.play()
		animationXPathAnimation.play()
		animationYPathAnimation.play()
		animationWidthPathAnimation.play()
		animationHeightPathAnimation.play()
		if addRotation then animationRotationZPathAnimation.play()
		animationOverlayOpacityPathAnimation.play()
		target.on Events.AnimationEnd, (animation, layer) ->
			if target.y == 400
				animationHasReachedStartPathAnimation.play()
			else
				animationHasReachedEndPathAnimation.play()
	
	previewFlow.onTap ->
		if stfsn.visible then playCustomTransition()
	
	###############################
	# DEBUG PANEL
	
	sketch.rewindStatusRecording.props = visible: true, opacity: 0
	
	addRecordingAreas = (layers) ->
		for layer in layers
			layer.onMouseOver ->
				if sketch.rewindToggleHandleActive.opacity == 1
					sketch.rewindStatusRecording.animate opacity: 1
					sketch.rewindStatusNormal.animate opacity: 0
			layer.onMouseOut ->
				sketch.rewindStatusRecording.animate opacity: 0
				sketch.rewindStatusNormal.animate opacity: 1
	
	addRecordingAreas([
		sketch.customTransitionShowPrevious
		sketch.customTransitionShowNext
		previewFlow
	])
	
	rewindHandle.onDragStart ->
		sketch.rotationZConnection.index = 8
		sketch.rotationZConnectionDefault.opacity = 0
		videoNodesDefault.visible = true
		videoPreviewDefault.visible = true
		sketch.rewindTime.visible = true
		sketch.rewindStatusNormal.visible = false
	
	rewindHandle.on "change:x", ->
		nodesSecond = Utils.modulate(rewindHandle.x, [92, 283], [0, videoNodesDefault.player.duration])
		previewSecond = Utils.modulate(rewindHandle.x, [92, 283], [0, videoPreviewDefault.player.duration])
		videoNodesDefault.player.currentTime = nodesSecond
		videoPreviewDefault.player.currentTime = previewSecond
		videoNodesRotation.player.currentTime = nodesSecond
		videoPreviewRotation.player.currentTime = previewSecond
		time = Utils.modulate(rewindHandle.x, [0, 283], [-3000, 0])
		sketch.rewindTime.html = parseFloat(time).toFixed(0) + " ms"
		if rewindHandle.x > 282 && !rewindHandle.draggable.isDragging
			sketch.rotationZConnectionDefault.opacity = 1
			videoNodesDefault.visible = false
			videoPreviewDefault.visible = false
			videoNodesRotation.visible = false
			videoPreviewRotation.visible = false
	
	rewindHandle.onDragEnd ->
		if rewindHandle.x > 282
			sketch.rotationZConnection.index = 5
		sketch.rewindTime.visible = false
		sketch.rewindStatusNormal.visible = true

# RESPONSIVE DESIGN

showCaseResponsiveDesignIsEnabled = false
navigationBarWidthPathAnimation = null
showMenuShowNextPathAnimation = null

enableShowCaseResponsiveDesign = () ->
	if showCaseResponsiveDesignIsEnabled == false
		showCaseResponsiveDesignIsEnabled = true
	else
		return
	
	sketch.showMenu2NodeHoverArea.addNodeSelectionAction(null, true)
	onTap = () -> sketch.layerManagementButtonsActive.visible = true
	sketch.menuButtonNodeHoverArea.addNodeSelectionAction(onTap, true)
	sketch.otherItemsNodeHoverArea.addNodeSelectionAction(onTap, true)
	
	sketch.showMenu2NodePL.addSizeConstraintModes (sizeMode) -> 
		if sizeMode == 0
			sketch.showMenuNextButton.y = 439
			sketch.showMenuPreviousButton.y = 548 
			sketch.showMenuPositionXField.opacity = .5
		else if sizeMode == 1
			sketch.showMenuNextButton.y = 377
			sketch.showMenuPreviousButton.y = 486 
			sketch.showMenuPositionXField.opacity = 0
		else if sizeMode == 2
			sketch.showMenuNextButton.y = 439
			sketch.showMenuPreviousButton.y = 548 
			sketch.showMenuPositionXField.opacity = 1
	
	sketch.otherItemsNodePL.addSizeConstraintModes()
	sketch.menuButtonNodePL.addSizeConstraintModes() 
	
	svg = """
	<svg width="58px" height="4px" viewBox="563 165 58 4" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
	    <path d="M601,167 L564,167" id="Path" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" fill="none"></path>
	</svg>
	"""
	showMenuShowNextPathAnimation = generatePathAnimation(
		sketch.showMenuShowNextPath, 1, "+", svg, 7, -18
	) 
	svg = """
	<svg width="243px" height="518px" viewBox="272 85 243 518" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
	    <path d="M439,86 C480.816974,86 505.147354,176.055953 511.991142,280.850511 M513.175263,303.144678 C517.829236,416.168958 502.786513,539.83045 468.047094,584.090852 M316,601 L273,601" id="Path" stroke="#FFB42F" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" fill="none"></path>
	</svg>
	"""
	navigationBarWidthPathAnimation = generatePathAnimation(
		sketch.navigationBarWidthPath, 1, "+", svg, 7, 3
	)

	sketch.navBarMobileSlicingPopup.addOpacityToggleState()
	sketch.navBarDesktopSlicingPopup.addOpacityToggleState()
	
	sketch.imageSlicingSettingIcon1.addMouseHoverState true, ->
		popupOpen = sketch.navBarMobileSlicingPopup
		sketch.navBarMobileSlicingPopup.animate("default")
	
	sketch.imageSlicingSettingIcon2.addMouseHoverState true, ->
		popupOpen = sketch.navBarDesktopSlicingPopup
		sketch.navBarDesktopSlicingPopup.animate("default")
	
	sketch.showMenuPositionXField.style = textFieldStyle
	s = previewFlow.width
	sketch.showMenuPositionXField.html = (( s - 720 ) / 2 + 538).toFixed(0)
	
	# POPUP PANEL
	 
	sketch.lelftSliceField.style = rightAlignedEditedTextFieldStyle
	sketch.lelftSliceField.html = (sketch.leftSliceHandle.x + 6).toFixed(0)
	sketch.leftSliceHandle.changeMouseOnHover("ew-resize")
	
	sketch.leftSliceHandle.makeMoveable (point) -> 
		point.y = sketch.leftSliceHandle.y
		sketch.lelftSliceField.html = (sketch.leftSliceHandle.x + 6).toFixed(0)
		return point
	
	sketch.sliceModes.addTapToggleState ->
		sketch.verticalSliceHandles.visible = !sketch.verticalSliceHandles.visible
	
	sketch.menuButtonNodeHoverArea.addPreviewInspectionFeature(sketch.menuIconInspector)
	sketch.menuButtonNodeHoverArea.addPreviewInspectionFeature(sketch.menuButtonInspector)
	sketch.otherItemsNodeHoverArea.addPreviewInspectionFeature(sketch.navigationBar1Inspector)
	sketch.otherItemsNodeHoverArea.addPreviewInspectionFeature(sketch.navigationBar2Inspector)

##############################################################

# TIPS

###
sketch.previewArea.props =
	#html: "<iframe style='position:absolute; width: 100%; height: 100%;' src='http://framerjs.com'></iframe>"

fun = (fu) ->
	print 1
	a = 5
	fu(a)
	print a

fun(
	((a) -> 
		print 2
		a = 6
		print a
	)
)
###

############################################################## 