Class {
	#name : #RBInlineParameterRefactoring,
	#superclass : #RBRemoveParameterRefactoring,
	#instVars : [
		'expressions'
	],
	#category : #'Refactoring-Core-Refactorings'
}

{ #category : #'instance creation' }
RBInlineParameterRefactoring class >> inlineParameter: aString in: aClass selector: aSelector [ 
	^self new 
		inlineParameter: aString
		in: aClass
		selector: aSelector
]

{ #category : #'instance creation' }
RBInlineParameterRefactoring class >> model: aRBSmalltalk inlineParameter: aString in: aClass selector: aSelector [ 
	^(self new)
		model: aRBSmalltalk;
		inlineParameter: aString
			in: aClass
			selector: aSelector;
		yourself
]

{ #category : #private }
RBInlineParameterRefactoring >> allExpressionsToInline [
	| coll |
	coll := Set new.
	self model allReferencesTo: oldSelector
		do: 
			[:each | 
			| tree |
			tree := each parseTree.
			tree notNil ifTrue: [coll addAll: (self expressionsToInlineFrom: tree)]].
	^coll asOrderedCollection
]

{ #category : #private }
RBInlineParameterRefactoring >> expressionsToInlineFrom: aTree [ 
	| searcher |
	searcher := RBParseTreeSearcher new.
	searcher matches: '``@obj ' , (self buildSelectorString: oldSelector)
		do: 
			[:aNode :answer | 
			answer
				add: (aNode arguments at: parameterIndex);
				yourself].
	^searcher executeTree: aTree initialAnswer: OrderedCollection new
]

{ #category : #'initialize-release' }
RBInlineParameterRefactoring >> inlineParameter: aString in: aClass selector: aSelector [
	oldSelector := aSelector.
	class := self classObjectFor: aClass.
	argument := aString
]

{ #category : #transforming }
RBInlineParameterRefactoring >> modifyImplementorParseTree: parseTree in: aClass [ 
	| node assignment |
	node := (parseTree arguments at: parameterIndex) copy.
	parseTree body addTemporaryNamed: node name.
	assignment := RBAssignmentNode variable: node copy value: expressions first.
	parseTree body addNodeFirst: assignment.
	super modifyImplementorParseTree: parseTree in: aClass
]

{ #category : #preconditions }
RBInlineParameterRefactoring >> myConditions [
	self getNewSelector.
	expressions := self allExpressionsToInline.
	^(RBCondition definesSelector: oldSelector in: class) 
		& ((RBCondition withBlock: [expressions isEmpty not]) 
				errorMacro: 'No callers. Use Remove Method instead.') 
			& ((RBCondition withBlock: [expressions size = 1]) 
					errorMacro: 'All values passed as this argument must be identical.') 
			& ((RBCondition withBlock: [expressions first isLiteralNode]) 
					errorMacro: 'All values passed must be literal.')
]

{ #category : #printing }
RBInlineParameterRefactoring >> storeOn: aStream [ 
	aStream nextPut: $(.
	self class storeOn: aStream.
	aStream
		nextPutAll: ' inlineParameter: ''';
		nextPutAll: argument;
		nextPutAll: ''' in: '.
	class storeOn: aStream.
	aStream
		nextPutAll: ' selector: #';
		nextPutAll: oldSelector;
		nextPut: $)
]
