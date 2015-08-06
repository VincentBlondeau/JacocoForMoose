Class {
	#name : #RBPushDownInstanceVariableRefactoring,
	#superclass : #RBVariableRefactoring,
	#category : #'Refactoring-Core-Refactorings'
}

{ #category : #preconditions }
RBPushDownInstanceVariableRefactoring >> preconditions [
	| references |
	references := RBCondition referencesInstanceVariable: variableName
				in: class.
	class realClass isNil 
		ifTrue: 
			[references 
				errorMacro: ('<1s> is referenced.' expandMacrosWith: variableName)]
		ifFalse: 
			[references
				errorMacro: ('<1s> is referenced.<n>Browse references?' 
							expandMacrosWith: variableName);
				errorBlock: 
						[self openBrowserOn: (RBBrowserEnvironment new instVarRefsTo: variableName
									in: class realClass)]].
	^(RBCondition definesInstanceVariable: variableName in: class) 
		& references not
]

{ #category : #transforming }
RBPushDownInstanceVariableRefactoring >> transform [
	class removeInstanceVariable: variableName.
	class subclasses do: [:each | each addInstanceVariable: variableName]
]
