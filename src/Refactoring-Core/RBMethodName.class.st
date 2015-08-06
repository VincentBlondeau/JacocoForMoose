Class {
	#name : #RBMethodName,
	#superclass : #Model,
	#instVars : [
		'selector',
		'arguments'
	],
	#category : #'Refactoring-Core-Support'
}

{ #category : #'instance creation' }
RBMethodName class >> selector: aSymbol arguments: stringCollection [ 
	^(self new)
		selector: aSymbol;
		arguments: stringCollection;
		yourself
]

{ #category : #accessing }
RBMethodName >> arguments [
	^arguments
]

{ #category : #accessing }
RBMethodName >> arguments: nameCollection [ 
	arguments := nameCollection.
	self changed: #arguments
]

{ #category : #testing }
RBMethodName >> isValid [
	^ (RBCondition checkMethodName: self selector in: self class) 
		and: [ self selector numArgs = self arguments size ]
]

{ #category : #printing }
RBMethodName >> printOn: aStream [
	| argumentStream |
	self isValid
		ifFalse: [ ^ aStream nextPutAll: '(invalid)' ].
	argumentStream := self arguments readStream.
	self selector keywords keysAndValuesDo: [ :key :part |
		key = 1 ifFalse: [ aStream space ].
		aStream nextPutAll: part.
		(self selector isUnary or: [ argumentStream atEnd ]) 
			ifTrue: [ ^ self ].
		aStream space; nextPutAll: argumentStream next ]
]

{ #category : #accessing }
RBMethodName >> selector [
	^selector
]

{ #category : #accessing }
RBMethodName >> selector: aSymbol [ 
	selector := aSymbol asSymbol.
	self changed: #selector
]
