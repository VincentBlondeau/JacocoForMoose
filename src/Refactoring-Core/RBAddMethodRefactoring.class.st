Class {
	#name : #RBAddMethodRefactoring,
	#superclass : #RBMethodRefactoring,
	#instVars : [
		'protocols',
		'source'
	],
	#category : #'Refactoring-Core-Refactorings'
}

{ #category : #'instance creation' }
RBAddMethodRefactoring class >> addMethod: aString toClass: aClass inProtocols: protocolList [ 
	^self new addMethod: aString
		toClass: aClass
		inProtocols: protocolList
]

{ #category : #'instance creation' }
RBAddMethodRefactoring class >> model: aRBSmalltalk addMethod: aString toClass: aClass inProtocols: protocolList [ 
	^(self new)
		model: aRBSmalltalk;
		addMethod: aString
			toClass: aClass
			inProtocols: protocolList;
		yourself
]

{ #category : #'initialize-release' }
RBAddMethodRefactoring >> addMethod: aString toClass: aClass inProtocols: protocolList [ 
	class := self classObjectFor: aClass.
	source := aString.
	protocols := protocolList
]

{ #category : #preconditions }
RBAddMethodRefactoring >> preconditions [
	| selector method |
	method := RBParser parseMethod: source
				onError: 
					[:string :position | 
					^RBCondition 
						withBlock: [self refactoringFailure: 'The sources could not be parsed']].
	selector := method selector.
	selector isNil ifTrue: [self refactoringFailure: 'Invalid source.'].
	^(RBCondition canUnderstand: selector in: class) not
]

{ #category : #printing }
RBAddMethodRefactoring >> storeOn: aStream [ 
	aStream nextPut: $(.
	self class storeOn: aStream.
	aStream
		nextPutAll: ' addMethod: ''';
		nextPutAll: source;
		nextPutAll: ''' toClass: '.
	class storeOn: aStream.
	aStream nextPutAll: ' inProtocols: '.
	protocols storeOn: aStream.
	aStream nextPut: $)
]

{ #category : #transforming }
RBAddMethodRefactoring >> transform [
	class compile: source classified: protocols
]
