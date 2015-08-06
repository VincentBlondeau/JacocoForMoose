"
RBMoveInstVarToClassRefactoring knows how to move instance variable from one class to another.

Instance Variables
	newClass:		<RBClass>

newClass
	- class, in which user moves an instance variable
"
Class {
	#name : #RBMoveInstVarToClassRefactoring,
	#superclass : #RBVariableRefactoring,
	#instVars : [
		'oldClass'
	],
	#category : #'Refactoring-Core-Refactorings'
}

{ #category : #'as yet unclassified' }
RBMoveInstVarToClassRefactoring class >> model: aRBSmalltalk variable: aVarName class: aClass oldClass: anOldClass [
	^(self new)
		model: aRBSmalltalk;
		variable: aVarName class: aClass;
		oldClass: anOldClass;
		yourself.
]

{ #category : #transforming }
RBMoveInstVarToClassRefactoring >> collectSendersOfInstVar [
	| brokenSenders subclasses hasInstVar |
	hasInstVar := false.
	brokenSenders := OrderedCollection new.
	oldClass superclass instVarNames
		do: [ :each | 
			each = variableName
				ifTrue: [ hasInstVar := true ] ].
	hasInstVar
		ifTrue: [ ^ brokenSenders ]
		ifFalse: [ 
			brokenSenders := (oldClass selectors
				select: [ :each | (oldClass methodNamed: each) sourceCode includesSubstring: variableName asString ]
				thenCollect: [ :each | oldClass methodNamed: each ]) asOrderedCollection.
			subclasses := oldClass subclasses.
			subclasses
				do: [ :subclass | 
					subclass selectors
						do: [ :each | 
							((subclass methodNamed: each) sourceCode includesSubstring: ' ' , variableName asString , ' ')
								ifTrue: [ brokenSenders add: (subclass methodNamed: each) ] ] ].
			^ brokenSenders ]
]

{ #category : #accessing }
RBMoveInstVarToClassRefactoring >> oldClass: aClass [
	oldClass := aClass
]

{ #category : #preconditions }
RBMoveInstVarToClassRefactoring >> preconditions [
	^ RBCondition
		withBlock: [ 
			(class hierarchyDefinesInstanceVariable: variableName)
				ifTrue: [ self refactoringError: 'Already defined in hierarchy' ].true ]
]

{ #category : #transforming }
RBMoveInstVarToClassRefactoring >> transform [
	| brokenSenders |
	class addInstanceVariable: variableName asString.
	oldClass removeInstVarNamed: variableName asString.
	brokenSenders := self collectSendersOfInstVar.
	brokenSenders ifNotEmpty: [ 
		Smalltalk tools messageList
			browse: brokenSenders 
			title: 'Broken methods' 
			autoSelect: brokenSenders first selector] 
]
