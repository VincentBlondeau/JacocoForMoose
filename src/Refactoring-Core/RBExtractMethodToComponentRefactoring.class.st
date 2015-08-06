Class {
	#name : #RBExtractMethodToComponentRefactoring,
	#superclass : #RBMethodRefactoring,
	#instVars : [
		'selector',
		'extractionInterval',
		'extractedMethodSelector'
	],
	#category : #'Refactoring-Core-Refactorings'
}

{ #category : #'instance creation' }
RBExtractMethodToComponentRefactoring class >> extract: anInterval from: aSelector in: aClass [ 
	^self new
		extract: anInterval
		from: aSelector
		in: aClass
]

{ #category : #'instance creation' }
RBExtractMethodToComponentRefactoring class >> model: aRBSmalltalk extract: anInterval from: aSelector in: aClass [ 
	^(self new)
		model: aRBSmalltalk;
		extract: anInterval
			from: aSelector
			in: aClass;
		yourself
]

{ #category : #'initialize-release' }
RBExtractMethodToComponentRefactoring >> extract: anInterval from: aSelector in: aClass [ 
	class := self classObjectFor: aClass.
	selector := aSelector.
	extractionInterval := anInterval
]

{ #category : #transforming }
RBExtractMethodToComponentRefactoring >> extractMethod [
	| refactoring |
	refactoring := RBExtractMethodRefactoring 
				model: self model
				extract: extractionInterval
				from: selector
				in: class.
	refactoring setOption: #methodName
		toUse: 
			[:ref :methodName | 
			extractedMethodSelector := ref 
						uniqueMethodNameFor: methodName arguments size.
			methodName
				selector: extractedMethodSelector;
				yourself].
	self performComponentRefactoring: refactoring
]

{ #category : #transforming }
RBExtractMethodToComponentRefactoring >> inlineForwarder [
	| refactoring |
	refactoring := RBInlineAllSendersRefactoring 
				model: self model
				sendersOf: extractedMethodSelector
				in: class.
	refactoring setOption: #inlineExpression toUse: [:ref :string | true].
	self performComponentRefactoring: refactoring
]

{ #category : #transforming }
RBExtractMethodToComponentRefactoring >> moveMethod [
	| variable refactoring |
	variable := self selectVariableToMoveMethodTo: extractedMethodSelector
				class: class.
	variable isNil ifTrue: [self refactoringFailure: 'Did not extract method'].
	refactoring := RBMoveMethodRefactoring 
				model: self model
				selector: extractedMethodSelector
				class: class
				variable: variable.
	self performComponentRefactoring: refactoring
]

{ #category : #preconditions }
RBExtractMethodToComponentRefactoring >> preconditions [
	^RBCondition empty
]

{ #category : #printing }
RBExtractMethodToComponentRefactoring >> storeOn: aStream [ 
	aStream nextPut: $(.
	self class storeOn: aStream.
	aStream nextPutAll: ' extract: '.
	extractionInterval storeOn: aStream.
	aStream
		nextPutAll: ' from: #';
		nextPutAll: selector;
		nextPutAll: ' in: '.
	class storeOn: aStream.
	aStream nextPut: $)
]

{ #category : #transforming }
RBExtractMethodToComponentRefactoring >> transform [
	self
		extractMethod;
		moveMethod;
		inlineForwarder
]
