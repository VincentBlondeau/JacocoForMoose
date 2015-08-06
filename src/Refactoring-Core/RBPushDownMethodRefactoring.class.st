Class {
	#name : #RBPushDownMethodRefactoring,
	#superclass : #RBMethodRefactoring,
	#instVars : [
		'selectors'
	],
	#category : #'Refactoring-Core-Refactorings'
}

{ #category : #'instance creation' }
RBPushDownMethodRefactoring class >> model: aRBSmalltalk pushDown: selectorCollection from: aClass [ 
	^(self new)
		model: aRBSmalltalk;
		pushDown: selectorCollection from: aClass;
		yourself
]

{ #category : #'instance creation' }
RBPushDownMethodRefactoring class >> pushDown: selectorCollection from: aClass [ 
	^self new pushDown: selectorCollection from: aClass
]

{ #category : #preconditions }
RBPushDownMethodRefactoring >> preconditions [
	| condition |
	condition := selectors 
		inject: RBCondition empty
		into: [ :cond :each | 
			cond & (RBCondition definesSelector: each in: class) 
				& (RBCondition subclassesOf: class referToSelector: each) not].
	^condition & (RBCondition isAbstractClass: class)
]

{ #category : #transforming }
RBPushDownMethodRefactoring >> pushDown: aSelector [ 
	| code protocols refactoring |
	code := class sourceCodeFor: aSelector.
	protocols := class protocolsFor: aSelector.
	refactoring := RBExpandReferencedPoolsRefactoring 
				model: self model
				forMethod: (class parseTreeFor: aSelector)
				fromClass: class
				toClasses: class subclasses.
	self performComponentRefactoring: refactoring.
	class subclasses do: 
			[:each | 
			(each directlyDefinesMethod: aSelector) 
				ifFalse: [each compile: code classified: protocols]]
]

{ #category : #'initialize-release' }
RBPushDownMethodRefactoring >> pushDown: selectorCollection from: aClass [ 
	class := self classObjectFor: aClass.
	selectors := selectorCollection
]

{ #category : #printing }
RBPushDownMethodRefactoring >> storeOn: aStream [ 
	aStream nextPut: $(.
	self class storeOn: aStream.
	aStream nextPutAll: ' pushDown: '.
	selectors asArray storeOn: aStream.
	aStream nextPutAll: ' from: '.
	class storeOn: aStream.
	aStream nextPut: $)
]

{ #category : #transforming }
RBPushDownMethodRefactoring >> transform [
	selectors do: [:each | self pushDown: each].
	selectors do: [:each | class removeMethod: each]
]
