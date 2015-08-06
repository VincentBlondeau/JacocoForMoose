Class {
	#name : #RBSplitClassRefactoring,
	#superclass : #RBRefactoring,
	#instVars : [
		'class',
		'instanceVariables',
		'newClassName',
		'referenceVariableName',
		'newClass'
	],
	#category : #'Refactoring-Core-Refactorings'
}

{ #category : #'instance creation' }
RBSplitClassRefactoring class >> class: class instanceVariables: instVars newClassName: className referenceVariableName: newVariable [ 
	^(self new)
		class: class
			instanceVariables: instVars
			newClassName: className
			referenceVariableName: newVariable;
		yourself
]

{ #category : #'instance creation' }
RBSplitClassRefactoring class >> model: aRBSmalltalk class: class instanceVariables: instVars newClassName: className referenceVariableName: newVariable [ 
	^(self new)
		model: aRBSmalltalk;
		class: class
			instanceVariables: instVars
			newClassName: className
			referenceVariableName: newVariable;
		yourself
]

{ #category : #'private-transforming' }
RBSplitClassRefactoring >> abstractReferenceTo: each [ 
	| setterMethod replacer accessorRef getterMethod |
	accessorRef := RBCreateAccessorsForVariableRefactoring 
				variable: each
				class: newClass
				classVariable: false.
	self performComponentRefactoring: accessorRef.
	getterMethod := accessorRef getterMethod.
	setterMethod := accessorRef setterMethod.
	replacer := RBParseTreeRewriter 
				variable: each
				getter: getterMethod
				setter: setterMethod
				receiver: referenceVariableName.
	self 
		convertClasses: class withAllSubclasses
		select: [:aClass | aClass whichSelectorsReferToInstanceVariable: each]
		using: replacer.
	self performComponentRefactoring: (RBRemoveInstanceVariableRefactoring 
				remove: each
				from: class)
]

{ #category : #transforming }
RBSplitClassRefactoring >> abstractVariableReferences [
	instanceVariables do: [:each | self abstractReferenceTo: each]
]

{ #category : #'private-transforming' }
RBSplitClassRefactoring >> addClass [
	self performComponentRefactoring: (RBAddClassRefactoring 
				model: self model
				addClass: newClassName
				superclass: Object
				subclasses: #()
				category: class category).
	newClass := self model classNamed: newClassName asSymbol
]

{ #category : #'private-transforming' }
RBSplitClassRefactoring >> addInstanceVariables [
	instanceVariables do: 
			[:each | 
			self performComponentRefactoring: (RBAddInstanceVariableRefactoring 
						model: self model
						variable: each
						class: newClass)]
]

{ #category : #'initialize-release' }
RBSplitClassRefactoring >> class: aClass instanceVariables: instVars newClassName: className referenceVariableName: newVariable [ 
	class := self model classFor: aClass.
	instanceVariables := instVars.
	newClassName := className.
	referenceVariableName := newVariable
]

{ #category : #transforming }
RBSplitClassRefactoring >> createNewClass [
	self
		addClass;
		addInstanceVariables
]

{ #category : #transforming }
RBSplitClassRefactoring >> createReference [
	self performComponentRefactoring: (RBAddInstanceVariableRefactoring 
				variable: referenceVariableName
				class: class)
]

{ #category : #preconditions }
RBSplitClassRefactoring >> preconditions [
	^(RBCondition isValidClassName: newClassName) 
		& (RBCondition isGlobal: newClassName in: self model) not 
			& (RBCondition isValidInstanceVariableName: referenceVariableName for: class) 
			& (RBCondition hierarchyOf: class definesVariable: referenceVariableName) 
					not 
			& (RBCondition isGlobal: referenceVariableName in: self model) not 
			& (RBCondition definesTemporaryVariable: referenceVariableName in: class) 
					not
]

{ #category : #printing }
RBSplitClassRefactoring >> storeOn: aStream [ 
	aStream nextPut: $(.
	self class storeOn: aStream.
	aStream nextPutAll: ' class: '.
	class storeOn: aStream.
	aStream nextPutAll: ' instanceVariables: '.
	instanceVariables asArray storeOn: aStream.
	aStream
		nextPutAll: ' newClassName: #';
		nextPutAll: newClassName;
		nextPutAll: ' referenceVariableName: ''';
		nextPutAll: referenceVariableName;
		nextPutAll: ''')'
]

{ #category : #transforming }
RBSplitClassRefactoring >> transform [
	self
		createNewClass;
		createReference;
		abstractVariableReferences
]
