Class {
	#name : #RBAccessorClassRefactoring,
	#superclass : #RBClassRefactoring,
	#category : #'Refactoring-Core-Refactorings'
}

{ #category : #preconditions }
RBAccessorClassRefactoring >> preconditions [
	^ self refactorings
		inject: RBCondition empty
		into: [ :result :each | result & each preconditions ]
]

{ #category : #accessing }
RBAccessorClassRefactoring >> refactorings [
	| class |
	class := self classObjectFor: className asSymbol.
	^  class instanceVariableNames collect: [ :each | 
		RBCreateAccessorsForVariableRefactoring
			variable: each class: class classVariable: false ]
]

{ #category : #transforming }
RBAccessorClassRefactoring >> transform [
	self refactorings do: [ :each | self performComponentRefactoring: each ]
]
