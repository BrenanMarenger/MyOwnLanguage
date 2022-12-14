﻿Object subclass: #QAnalyzer

	super initialize.
	env := QEnvironment new.
	errors := OrderedCollection new.! !

	^ env! !

	env := anObject.! !

	^ errors! !

	errors := anObject.! !

		
	^aQuestIdentifier id! !

	| var |
	var := aQuestLootDeclaration type accept: self.
	[self env
		bind: (aQuestLootDeclaration name accept: self)
		variable: var]
			on: QError
			do: [:ex | self errors add: ex].
	^var! !
	
	aQuestLootSection loot
		do: [:each | each accept: self]! !
	
	aQuestQuest lootSection accept: self.
	aQuestQuest spellsSection accept: self.
	aQuestQuest storySection accept: self.! !
	
	aQuestSpellsSection spells
		do: [:each | each accept: self]! !
	
	aQuestStorySection statements
		do: [:each | each accept: self]! !
	
	^QVariable new
		type: aQuestType type;
		yourself! !
	
	| analyzer ast |
	analyzer := self new.
	ast := QuestParser parse: aString.
	ast accept: analyzer.
	^analyzer errors! !

	| errors |
	errors := QAnalyzer analyze: self arithmeticOperatorQuest.
	self assert: (errors size = 1).
! !

	| errors |
	errors := QAnalyzer analyze: self multipleDeclarationVariableQuest.
	self assert: (errors size = 1).
! !

	| errors |
	errors := QAnalyzer analyze: self nanoQuest.
	self assert: errors isEmpty.
! !

	| errors |
	errors := QAnalyzer analyze: self undeclaredVarQuest.
	self assert: (errors size = 1).
! !

	^'quest Nano
story
!!'! !

	^'quest Nano
loot
	thereCanBeOnlyOne isA string
	thereCanBeOnlyOne isAn integer
!!
story
!!'! !

	^'quest Nano
story
!!'! !

	^'quest Nano
story
!!'! !