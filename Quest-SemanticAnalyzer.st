Object subclass: #QAnalyzer	instanceVariableNames: 'env errors'	classVariableNames: ''	poolDictionaries: ''	category: 'Quest-SemanticAnalyzer'!!QAnalyzer methodsFor: 'initialize-release' stamp: 'jws 12/5/2022 10:32'!initialize

	super initialize.
	env := QEnvironment new.
	errors := OrderedCollection new.! !!QAnalyzer methodsFor: 'accessing' stamp: 'jws 12/5/2022 10:32'!env

	^ env! !!QAnalyzer methodsFor: 'accessing' stamp: 'jws 12/5/2022 10:32'!env: anObject

	env := anObject.! !!QAnalyzer methodsFor: 'accessing' stamp: 'jws 12/5/2022 10:32'!errors

	^ errors! !!QAnalyzer methodsFor: 'accessing' stamp: 'jws 12/5/2022 10:32'!errors: anObject

	errors := anObject.! !!QAnalyzer methodsFor: 'visiting' stamp: 'BKM 12/9/2022 10:38'!visitQuestArithmeticExpression: aQuestArithmeticExpression 	| type1 type2 |	type1 := (aQuestArithmeticExpression expression1 accept: self).	type2 := (aQuestArithmeticExpression expression2 accept: self).	(type1 class = QInteger and: [type2 class = QInteger])		ifFalse: [self errors add: (QTypeMismatch new messageText: 'arithmetic exp'; yourself)].			! !!QAnalyzer methodsFor: 'visiting' stamp: 'BKM 12/9/2022 10:53'!visitQuestAssigmentStatement: aVisitQuestAssigmentStatement 	| var valueType |	var := [self env fetchVariable: (aVisitQuestAssigmentStatement id accept: self)]		on: QError		do:[:ex | self errors add: ex. ex return: nil].	valueType := [aVisitQuestAssigmentStatement expression accept: self]		on: QError		do:[:ex | self errors add: ex. ex return: nil].	(var notNil and: [valueType notNil])		ifFalse: [^self].	[var value: valueType sampleValue]		on: QError		do: [:ex | self errors add: ex]		! !!QAnalyzer methodsFor: 'visiting' stamp: 'BKM 12/9/2022 10:39'!visitQuestBooleanLiteral: aQuestBooleanLiteral 	^QBoolean default.! !!QAnalyzer methodsFor: 'visiting' stamp: 'jws 12/5/2022 10:47'!visitQuestIdentifier: aQuestIdentifier 

		
	^aQuestIdentifier id! !!QAnalyzer methodsFor: 'visiting' stamp: 'jws 12/5/2022 10:44'!visitQuestLootDeclaration: aQuestLootDeclaration 

	| var |
	var := aQuestLootDeclaration type accept: self.
	[self env
		bind: (aQuestLootDeclaration name accept: self)
		variable: var]
			on: QError
			do: [:ex | self errors add: ex].
	^var! !!QAnalyzer methodsFor: 'visiting' stamp: 'jws 12/5/2022 10:42'!visitQuestLootSection: aQuestLootSection 
	
	aQuestLootSection loot
		do: [:each | each accept: self]! !!QAnalyzer methodsFor: 'visiting' stamp: 'BKM 12/9/2022 10:39'!visitQuestNumericLiteral: aQuestNumericLiteral 		^QInteger default.! !!QAnalyzer methodsFor: 'visiting' stamp: 'jws 12/5/2022 10:41'!visitQuestQuest: aQuestQuest 
	
	aQuestQuest lootSection accept: self.
	aQuestQuest spellsSection accept: self.
	aQuestQuest storySection accept: self.! !!QAnalyzer methodsFor: 'visiting' stamp: 'BKM 12/9/2022 10:25'!visitQuestScribeStatement: aQuestScribeStatement 	aQuestScribeStatement expression accept: self.! !!QAnalyzer methodsFor: 'visiting' stamp: 'jws 12/5/2022 10:47'!visitQuestSpellsSection: aQuestSpellsSection 
	
	aQuestSpellsSection spells
		do: [:each | each accept: self]! !!QAnalyzer methodsFor: 'visiting' stamp: 'jws 12/5/2022 10:48'!visitQuestStorySection: aQuestStorySection 
	
	aQuestStorySection statements
		do: [:each | each accept: self]! !!QAnalyzer methodsFor: 'visiting' stamp: 'jws 12/5/2022 10:46'!visitQuestType: aQuestType 
	
	^QVariable new
		type: aQuestType type;
		yourself! !!QAnalyzer methodsFor: 'visiting' stamp: 'BKM 12/9/2022 10:30'!visitQuestVariableReference: aQuestVariableReference 		^[(self env fetchVariable: (aQuestVariableReference identifier accept: self)) type]		on: QError		do: [: ex | self errors add: ex. ex return: nil]! !"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!QAnalyzer class	instanceVariableNames: ''!!QAnalyzer class methodsFor: 'analyzing' stamp: 'jws 12/5/2022 10:39'!analyze: aString 
	
	| analyzer ast |
	analyzer := self new.
	ast := QuestParser parse: aString.
	ast accept: analyzer.
	^analyzer errors! !TestCase subclass: #QAnalyzerTestCase	instanceVariableNames: ''	classVariableNames: ''	poolDictionaries: ''	category: 'Quest-SemanticAnalyzer'!!QAnalyzerTestCase methodsFor: 'running' stamp: 'BKM 12/9/2022 10:32'!testArithmeticOperatorQuest

	| errors |
	errors := QAnalyzer analyze: self arithmeticOperatorQuest.
	self assert: (errors size = 1).
! !!QAnalyzerTestCase methodsFor: 'running' stamp: 'BKM 12/9/2022 10:17'!testMultipleVariableDeclaration

	| errors |
	errors := QAnalyzer analyze: self multipleDeclarationVariableQuest.
	self assert: (errors size = 1).	self assert: (errors first class name = #QMultiplyDeclared).	self assert: (errors first messageText = 'thereCanBeOnlyOne').
! !!QAnalyzerTestCase methodsFor: 'running' stamp: 'BKM 12/9/2022 10:04'!testNoErrors

	| errors |
	errors := QAnalyzer analyze: self nanoQuest.
	self assert: errors isEmpty.
! !!QAnalyzerTestCase methodsFor: 'running' stamp: 'BKM 12/9/2022 10:23'!testUndeclaredVarQuest

	| errors |
	errors := QAnalyzer analyze: self undeclaredVarQuest.
	self assert: (errors size = 1).
! !!QAnalyzerTestCase methodsFor: 'accessing' stamp: 'BKM 12/9/2022 10:32'!arithmeticOperatorQuest

	^'quest Nano
story	scribe 9 + true
!!'! !!QAnalyzerTestCase methodsFor: 'accessing' stamp: 'jws 12/5/2022 10:40'!multipleDeclarationVariableQuest

	^'quest Nano
loot
	thereCanBeOnlyOne isA string
	thereCanBeOnlyOne isAn integer
!!
story
!!'! !!QAnalyzerTestCase methodsFor: 'accessing' stamp: 'BKM 12/9/2022 10:03'!nanoQuest

	^'quest Nano
story
!!'! !!QAnalyzerTestCase methodsFor: 'accessing' stamp: 'BKM 12/9/2022 10:20'!undeclaredVarQuest

	^'quest Nano
story	scribe iAmNotGroot
!!'! !