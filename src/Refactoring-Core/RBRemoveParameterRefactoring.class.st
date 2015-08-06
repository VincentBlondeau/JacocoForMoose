Class {
	#name : #RBRemoveParameterRefactoring,
	#superclass : #RBChangeMethodNameRefactoring,
	#instVars : [
		'parameterIndex',
		'argument'
	],
	#category : #'Refactoring-Core-Refactorings'
}

{ #category : #'instance creation' }
RBRemoveParameterRefactoring class >> model: aRBSmalltalk removeParameter: aString in: aClass selector: aSelector [ 
	^(self new)
		model: aRBSmalltalk;
		removeParameter: aString
			in: aClass
			selector: aSelector;
		yourself
]

{ #category : #'instance creation' }
RBRemoveParameterRefactoring class >> removeParameter: aString in: aClass selector: aSelector [
	^self new removeParameter: aString in: aClass selector: aSelector
]

{ #category : #private }
RBRemoveParameterRefactoring >> computeNewSelector [
	| keywords stream |
	oldSelector numArgs == 0 
		ifTrue: [self refactoringFailure: 'This method contains no arguments'].
	oldSelector isInfix 
		ifTrue: [self refactoringFailure: 'Cannot remove parameters of infix selectors'].
	keywords := oldSelector keywords asOrderedCollection.
	keywords size = 1 ifTrue: [^(keywords first copyWithout: $:) asSymbol].
	keywords removeAt: parameterIndex.
	stream := WriteStream on: ''.
	keywords do: [:each | stream nextPutAll: each].
	^stream contents asSymbol
]

{ #category : #transforming }
RBRemoveParameterRefactoring >> getNewSelector [
	| tree |
	(class directlyDefinesMethod: oldSelector)
		ifFalse: [self refactoringFailure: 'Method doesn''t exist'].
	tree := class parseTreeFor: oldSelector.
	tree isNil ifTrue: [self refactoringFailure: 'Cannot parse sources'].
	parameterIndex := tree argumentNames indexOf: argument ifAbsent: [self refactoringFailure: 'Select a parameter!!'].
	permutation := (1 to: oldSelector numArgs)
				copyWithout: parameterIndex.
	newSelector := self computeNewSelector
]

{ #category : #transforming }
RBRemoveParameterRefactoring >> hasReferencesToTemporaryIn: each [ 
	| tree |
	tree := each parseTreeFor: oldSelector.
	tree isNil ifTrue: [self refactoringFailure: 'Cannot parse sources.'].
	^tree references: (tree argumentNames at: parameterIndex)
]

{ #category : #preconditions }
RBRemoveParameterRefactoring >> myConditions [
	| imps |
	imps := self model allImplementorsOf: oldSelector.
	self getNewSelector.
	^imps inject: (RBCondition definesSelector: oldSelector in: class)
		into: 
			[:cond :each | 
			cond 
				& (RBCondition withBlock: [(self hasReferencesToTemporaryIn: each) not]
						errorString: 'This argument is still referenced in at least one implementor!!')]
]

{ #category : #'initialize-release' }
RBRemoveParameterRefactoring >> removeParameter: aString in: aClass selector: aSelector [ 
	oldSelector := aSelector.
	class := self classObjectFor: aClass.
	argument := aString
]

{ #category : #printing }
RBRemoveParameterRefactoring >> storeOn: aStream [ 
	aStream nextPut: $(.
	self class storeOn: aStream.
	aStream
		nextPutAll: ' removeParameter: ''';
		nextPutAll: argument;
		nextPutAll: ''' in: '.
	class storeOn: aStream.
	aStream
		nextPutAll: ' selector: #';
		nextPutAll: oldSelector.
	aStream nextPut: $)
]
