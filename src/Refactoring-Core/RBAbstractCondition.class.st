Class {
	#name : #RBAbstractCondition,
	#superclass : #Object,
	#instVars : [
		'errorMacro'
	],
	#category : #'Refactoring-Core-Conditions'
}

{ #category : #'logical operations' }
RBAbstractCondition >> & aCondition [ 
	^RBConjunctiveCondition new left: self right: aCondition
]

{ #category : #checking }
RBAbstractCondition >> check [
	self subclassResponsibility
]

{ #category : #accessing }
RBAbstractCondition >> errorBlock [
	^self errorBlockFor: false
]

{ #category : #private }
RBAbstractCondition >> errorBlockFor: aBoolean [ 
	^nil
]

{ #category : #private }
RBAbstractCondition >> errorMacro [
	^errorMacro isNil
		ifTrue: ['unknown']
		ifFalse: [errorMacro]
]

{ #category : #private }
RBAbstractCondition >> errorMacro: aString [ 
	errorMacro := aString
]

{ #category : #accessing }
RBAbstractCondition >> errorString [
	^self errorStringFor: false
]

{ #category : #private }
RBAbstractCondition >> errorStringFor: aBoolean [
	^self errorMacro expandMacrosWith: aBoolean
]

{ #category : #'logical operations' }
RBAbstractCondition >> not [
	^RBNegationCondition on: self
]

{ #category : #'logical operations' }
RBAbstractCondition >> | aCondition [ 
	"(A | B) = (A not & B not) not"

	^(self not & aCondition not) not
]
