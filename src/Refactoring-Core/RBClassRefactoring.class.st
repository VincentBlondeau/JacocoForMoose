Class {
	#name : #RBClassRefactoring,
	#superclass : #RBRefactoring,
	#instVars : [
		'className'
	],
	#category : #'Refactoring-Core-Refactorings'
}

{ #category : #'instance creation' }
RBClassRefactoring class >> className: aName [
	^self new className: aName
]

{ #category : #'instance creation' }
RBClassRefactoring class >> model: aRBSmalltalk className: aName [ 
	^(self new)
		model: aRBSmalltalk;
		className: aName;
		yourself
]

{ #category : #'initialize-release' }
RBClassRefactoring >> className: aName [
	className := aName
]
