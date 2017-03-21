
# INFO

Framer.Info =
	title: "Framer Feature Ideas"
	author: "Emin İnanç Ünlü"

##############################################################

# PROJECT

sketch = Framer.Importer.load("imported/Design@1x")
{TextLayer} = require 'TextLayer'
Framer.Extras.Hints.disable()
document.body.style.cursor = "auto"

sketch.presentation.props = originX: 0, originY: 0
sketch.presentation.center()

# VARIABLES

animationOptionsSpring = {curve: "spring(300, 35, 0)"}
animationOptionsFastEase = {curve: "ease", time: 0.15}
animationOptionsEase = {curve: "ease", time: 0.3}
supportsCSSBackdropFilter = CSS.supports("(-webkit-backdrop-filter: blur())")
macOSBackgroundBlurStyle = "-webkit-backdrop-filter": "blur(10px)"
if !supportsCSSBackdropFilter
	macOSBackgroundBlurStyle = "background-color": "#DFDFDF"

activePanel = null
rightClick = false
activeCodeSections = []
previousSections = ["root"]
rightClickedSection = null
codeSectionsNavigation = null

# UTILITIES

newPanelOpened = (panel) ->
	activePanel = panel
	sketch.transparentOverlay.visible = true

Layer::duplicate = () ->
	copy = @.copy()
	copy.name += "_copy"
	sketch[copy.name] = copy
	for object in copy.descendants
		object.name += "_copy"
		sketch[object.name] = object
	return copy

Layer::changeMouseOnHover = (mouseStyle) -> 
	this.onMouseOver ->
		if this.opacity == 0 then return
		document.body.style.cursor = mouseStyle
	this.onMouseOut ->
		document.body.style.cursor = "auto"

Layer::addOpacityToggleState = (startHidden = true) ->
	this.visible = true
	this.states =
		default: opacity: 1, ignoreEvents: false
		hidden: opacity: 0, ignoreEvents: true
	this.states.animationOptions = animationOptionsFastEase
	this.on Events.StateSwitchStart, (from, to) ->
		if from is "hidden" then this.y -= 5000
	this.on Events.StateSwitchEnd, (from, to) ->
		if from is "default" then this.y += 5000
	if startHidden then this.stateSwitch("hidden")

Array::insert = (item, index) ->
	return this[0..index-1].concat(item).concat(this[index..])

##############################################################

# SETUP

Framer.Defaults.Animation = animationOptionsSpring

closeActivePanel = () ->
	if activePanel
		activePanel.animate("hidden")
		activePanel = null
		sketch.transparentOverlay.visible = false

sketch.transparentOverlay.onTap ->
	closeActivePanel()

for codeSection in sketch.codes.children
	codeSection.scrollVertical = true
	codeSection.children[0].changeMouseOnHover("text")
sketch.layerList.scrollVertical = true
sketch.lineNumbers.changeMouseOnHover("auto")

Utils.interval 0.6, ->
	cursors = [
		sketch.rootCursor
	]
	for cursor in cursors
		cursor.visible = !cursor.visible

Events.wrap(window).addEventListener "keydown", (event) ->
	if event.keyCode == 37 
		rightClick = true

Events.wrap(window).addEventListener "keyup", (event) ->
	if event.keyCode == 37 
		rightClick = false

# CODE NAVIGATION

sketch.codeNavigationDropdownMenuBG.props = 
	style: macOSBackgroundBlurStyle
	borderRadius: 5
sketch.codeNavigationDropdownMenuBG.changeMouseOnHover("auto")
sketch.codeNavigationDropdownMenu.addOpacityToggleState()

showCodeNavigationDropdownMenu = (mousePoint) ->
	newPanelOpened(sketch.codeNavigationDropdownMenu)
	sketch.codeNavigationDropdownMenu.animate("default")
	mousePoint = {x: mousePoint.x - 33, y: mousePoint.y - 55}
	sketch.codeNavigationDropdownMenu.point = mousePoint

Layer::addMenuTapAction = () ->
	normalLabel = this.children[2]
	hoverLabel = this.children[1]
	selectionBG = this.children[0]
	this.onMouseOver ->
		normalLabel.visible = false
		hoverLabel.visible = true
		selectionBG.visible = true
	this.onMouseOut ->
		normalLabel.visible = true
		hoverLabel.visible = false
		selectionBG.visible = false
	this.onTapStart ->
		normalLabel.visible = true
		hoverLabel.visible = false
		selectionBG.visible = false
	this.onTapEnd ->
		normalLabel.visible = false
		hoverLabel.visible = true
		selectionBG.visible = true
	if this.name isnt "closeSection"
		this.onTap ->
			layer = this
			Utils.delay 0.2, ->
				sectionName = layer.name.substring(11)
				activeCodeSections[layer.name.substring(6,7)] = layer.name.substring(5)
				selectSection(sectionName)
				closeActivePanel()
 
sketch.closeSection.addMenuTapAction()
for item in sketch.menuLevel1.children
	item.addMenuTapAction()
for item in sketch.menuLevel2.children
	item.addMenuTapAction()

sketch.closeSection.onTap ->
	Utils.delay 0.2, ->
		previousSections.pop()
		activeCodeSections[rightClickedSection.substring(1,2)] = null
		sectionName = previousSections[previousSections.length-1]
		recreateCodeSectionsNavigation(sectionName)
		selectSection(sectionName)
		closeActivePanel()
		leftover = false
		for item in activeCodeSections
			if !item then continue
			leftover = true
		if !leftover then closeCodeNavigationBar()

sketch.codeNavigationBar.visible = false
sketch.codeSectionsReference.visible = false
text = sketch.rootSection.children[0].convertToTextLayer()
text.centerY(-2)
text = sketch.codeSection.children[0].convertToTextLayer()
text.autoSize = true
text.centerY(0.5)

recreateCodeSectionsNavigation = (selectedSectionName) ->
	codeSectionsNavigationOld = codeSectionsNavigation
	codeSectionsNavigation = sketch.codeSectionsReference.duplicate()
	codeSectionsNavigation.parent = sketch.codeNavigationBar
	sketch.siblingIcon_copy.x = -1000
	sketch.rootSection_copy.onTap ->
		selectSection("root")
		sketch.rootCodes.y = 30
	
	maxX = 0
	lastSection = null
	selectedSection = sketch.rootSection_copy
	previousIndex = null
	
	for sectionName, i in activeCodeSections
		if !sectionName then continue
		if !lastSection
			lastSection = sketch.codeSection_copy
		else
			maxX = lastSection.maxX
			previousLevel = activeCodeSections[previousIndex].substring(4,5)
			currentLevel = activeCodeSections[i].substring(4,5)
			divider = sketch.siblingIcon_copy.copy()
			if currentLevel > previousLevel
				divider.destroy()
				divider = sketch.childrenIcon_copy.copy()
			divider.props = 
				parent: codeSectionsNavigation
				x: maxX + 3
			lastSection = lastSection.copy()
			lastSection.props = 
				parent: codeSectionsNavigation
				x: maxX + 3 + 2 + 4
		sectionName = sectionName.substring(6)
		lastSection.linkName = sectionName
		lastSection.fullName = activeCodeSections[i]
		lastSection.onTap (event) ->
			if rightClick
				rightClickedSection = this.fullName
				showCodeNavigationDropdownMenu(event.point)
			else
				selectSection(this.linkName)
		text = sectionName.toUpperCase().replace(/_/g, " ")
		lastSection.children[0].text = text
		lastSection.width = lastSection.children[0].width + 6
		if sectionName is selectedSectionName
			selectedSection = lastSection
		previousIndex = i
	
	for layer in codeSectionsNavigation.children
		if layer.name is "codeSection_copy"
			layer.children[0].color = "rgba(255,255,255,0.5)"
	selectedSection.children[0].color = "rgba(255,255,255,0.8)"
	
	codeSectionsNavigation.visible = true
	codeSectionsNavigationOld?.destroy()

selectSection = (sectionName) ->
	sketch.codeNavigationBar.visible = true
	for codeSection in sketch.codes.children
		codeSection.visible = false
	if sectionName isnt previousSections[previousSections.length-1]
		previousSections.push(sectionName)
	sketch["#{sectionName}Codes"].visible = true
	recreateCodeSectionsNavigation(sectionName)

Layer::makeCodeSectionLink = () ->
	this.onTap ->
		activeCodeSections[this.name.substring(1,2)] = this.name
		selectSection(this.name.substring(6))

codeSectionLinks = [
	sketch.I1_L1_info
	sketch.I2_L1_globals
	sketch.I3_L1_navigation_bar
	sketch.I4_L1_tab_bar
	sketch.I5_L1_screens
	sketch.I6_L2_moments_screen
	sketch.I7_L2_new_post_screen
]
for link in codeSectionLinks
	link.changeMouseOnHover("auto")
	link.makeCodeSectionLink()

closeCodeNavigationBar = () ->
	sketch.codeNavigationBar.visible = false
	activeCodeSections = []
	previousSections = ["root"]
	lastSection = null
	codeSectionsNavigation.destroy()
	for layer in sketch.codes.children
		layer.visible = false
	sketch.rootCodes.visible = true
	sketch.rootCodes.y = 0

sketch.closeCodeNavigationBar.onTap ->
	closeCodeNavigationBar()

# LAYER PANEL

layerListItems = [
	"00_fullScreenFlow",
	"01_momentsScreen",
	"02_tabBar",
	"02_navBar",
	"03_statusBar",
	"03_navBarDefaultContent",
	"04_filterIcon",
	"04_postIcon",
	"04_momentsSections",
	"05_followingSection",
	"05_matchSection",
	"04_i_filtersInfo",
	"03_navBarFilterPanelContent",
	"04_resetFiltersButton",
	"04_applyFiltersButton",
	"02_filterPanel",
	"03_filterPanelNotFiltered",
	"03_i_filterPanelFiltered",
	"02_filterPanelOverlay",
	"02_sections",
	"03_content",
	"04_itemList2",
	"05_content",
	"06_postButton",
	"06_item",
	"06_item1",
	"06_newMembers",
	"07_newMemberList",
	"08_content",
	"09_item5",
	"10_playIcon",
	"10_content",
	"09_item6",
	"09_item7",
	"10_playIcon1",
	"10_content1",
	"09_item8",
	"06_item2",
	"06_item3",
	"06_item4",
	"04_itemList1",
	"05_content",
	"06_postButton",
	"06_item",
	"06_item1",
	"06_newMembers",
	"07_newMemberList",
	"08_content",
	"09_item5",
	"10_playIcon",
	"10_content",
	"09_item6",
	"09_item7",
	"10_playIcon1",
	"10_content1",
	"09_item8",
	"06_item2",
	"06_item3",
	"06_item4",
	"01_i_overlay",
	"00_newPostScreen",
	"01_sendPostButton",
	"01_cancelPostButton",
	"01_previousPostingStateButton",
	"01_nextPostingStateButton",
	"01_postCategories",
	"02_i_postCategories4",
	"02_i_postCategories3",
	"02_i_postCategories2",
	"02_postCategories1",
	"01_newPostWrapper",
	"02_newPost1",
	"02_i_newPost2",
	"02_i_newPost3",
	"02_i_newPost4",
	"01_bg"
]

##############################################################
# CREATION AND HOVER

parentLayerLabel = sketch.parentLayer.children[1].convertToTextLayer()
parentLayerLabel.centerY(-1)
parentLayerLabel.autoSize = true

parentLayerBG = sketch.parentLayer.children[0]
parentLayerBG.props = 
	backgroundColor: "666666"
	borderRadius: 2
	image: null

generateLayerItems = () ->
	reference = sketch.layerListItemReference
	label = reference.children[3].convertToTextLayer()
	label.centerY(-2)
	label.x += 1
	label.name = "label"
	line = reference.children[1].children[0]
	line.image = null
	line.backgroundColor = "rgba(0,0,0,0.18)"
	previousY = 2
	highlightedLayers = []
	parentLayer = null
	for item in layerListItems
		# Create
		newItem = reference.copy()
		newItem.props =
			name: item
			parent: sketch.layers
		newItem.y += previousY
		level = parseInt(item.substring(0,2))
		label = newItem.children[3]
		label.x = 12 + 12 * level
		visible = item.substring(3,5) isnt "i_"
		if visible
			label.text = item.substring(3)
		else 
			label.text = item.substring(5)
			label.opacity = 0.5
		if level > 0
			line = newItem.children[1].children[0]
			line.visible = true
		if level > 1
			for i in [1..level-1]
				newLine = line.copy()
				newLine.parent = newItem.children[1]
				newLine.x += 12 * i
		previousY = newItem.maxY
		# Hover
		length = sketch.layers.children.length
		newItem.onMouseOver ->
			label = this.children[3]
			if label.text is "fullScreenFlow"
				sketch.fullScreenFlowCodes.visible = true
			else
				sketch.noMatchCodes.visible = true
			if label.opacity is 0.5
				label.opacity = 0.99
			label.color = "rgba(0,0,0,0.9)"
			level = parseInt(this.name.substring(0,2))
			i = length - this.index + 2
			while i < length
				nextLayer = sketch.layers.children[i]
				highlightedLayers.push(nextLayer)
				nextLevel = parseInt(nextLayer.name.substring(0,2))
				if nextLevel >= level
					line = nextLayer.children[1].children[level-1]
					line?.backgroundColor = "rgba(0,0,0,0.6)"
				else
					i = sketch.layers.children.length
					highlightedLayers.pop()
				i++
			i = length - this.index + 1
			while i >= 0
				nextLayer = sketch.layers.children[i]
				highlightedLayers.push(nextLayer)
				nextLevel = parseInt(nextLayer.name.substring(0,2))
				if nextLevel >= level
					line = nextLayer.children[1].children[level-1]
					line?.backgroundColor = "rgba(0,0,0,0.6)"
				else
					i = -1
					highlightedLayers.pop()
					if nextLayer.y - sketch.layerList.scrollY < -30
						sketch.parentLayer.props =
							visible: true, x: 16 + nextLevel * 12
						parentLayerLabel.text = nextLayer.children[3].text
						parentLayerBG.width = parentLayerLabel.width + 14
				i--
		newItem.onMouseOut ->
			sketch.fullScreenFlowCodes.visible = false
			sketch.noMatchCodes.visible = false
			label = this.children[3]
			if label.opacity is 0.99
				label.opacity = 0.5
			label.color = "rgba(0,0,0,0.6)"
			level = parseInt(this.name.substring(0,2))
			for layer in highlightedLayers
				line = layer.children[1].children[level-1]
				line?.backgroundColor = "rgba(0,0,0,0.18)"
			highlightedLayers = []
			sketch.parentLayer.visible = false
	reference.destroy()
	sketch.layers.height = sketch.layers.contentFrame().height
	# Reverse Indexes
	length = sketch.layers.children.length
	for item, i in sketch.layers.children
		index = length + 1 - i
		item.index = index

generateLayerItems()

##############################################################
# RESIZING

clickedLayer = null
layerListDefaultHeight = sketch.layers.height

for layer in sketch.layers.children
	layer.onTap ->
		newHeight = layerListDefaultHeight
		if sketch.layers.height is layerListDefaultHeight
			clickedLayer = this
			level = parseInt(this.name.substring(0,2))
			length = sketch.layers.children.length
			i = length - this.index + 2
			while i < length
				nextLayer = sketch.layers.children[i]
				nextLevel = parseInt(nextLayer.name.substring(0,2))
				if nextLevel > level
					newHeight -= this.height
				else
					i = length
				i++
		animationTime = 0.15 + 0.0005 * Math.abs(sketch.layers.height - newHeight)
		animationTime = Math.min(animationTime, 0.40)
		sketch.layers.animate
			height: newHeight
			options: curve: "ease", time: animationTime

layerListPreviousHeight = layerListDefaultHeight
sketch.layers.on "change:height", ->
	deltaY = layerListPreviousHeight - this.height
	layerListPreviousHeight = this.height
	for layer in sketch.layers.children
		if layer.id > clickedLayer.id
			layer.y -= deltaY

