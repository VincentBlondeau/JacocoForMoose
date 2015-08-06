Class {
	#name : #RBRenameClassRefactoring,
	#superclass : #RBClassRefactoring,
	#instVars : [
		'newName',
		'class'
	],
	#category : #'Refactoring-Core-Refactorings'
}

{ #category : #'instance creation' }
RBRenameClassRefactoring class >> model: aRBSmalltalk rename: aClass to: aNewName [ 
	^(self new)
		model: aRBSmalltalk;
		className: aClass name newName: aNewName;
		yourself
]

{ #category : #'instance creation' }
RBRenameClassRefactoring class >> rename: aClass to: aNewName [
	^self new className: aClass name newName: aNewName
]

{ #category : #'initialize-release' }
RBRenameClassRefactoring >> className: aName newName: aNewName [ 
	className := aName asSymbol.
	class := self model classNamed: className.
	newName := aNewName asSymbol
]

{ #category : #preconditions }
RBRenameClassRefactoring >> preconditions [
	^(RBCondition withBlock: [class notNil and: [class isMeta not]]
		errorString: className , ' is not a valid class name') 
			& (RBCondition isValidClassName: newName) 
			& (RBCondition isGlobal: newName in: self model) not
]

{ #category : #transforming }
RBRenameClassRefactoring >> renameReferences [
	| replacer |
	replacer := (RBParseTreeRewriter replaceLiteral: className with: newName)
				replace: className with: newName;
				replaceArgument: newName
					withValueFrom: 
						[:aNode | 
						self 
							refactoringFailure: newName , ' already exists within the reference scope'];
				yourself.
	self model allReferencesToClass: class
		do: 
			[:method | 
			(method modelClass hierarchyDefinesVariable: newName) 
				ifTrue: 
					[self refactoringFailure: newName , ' is already defined in hierarchy of ' 
								, method modelClass printString].
			self 
				convertMethod: method selector
				for: method modelClass
				using: replacer]
]

{ #category : #printing }
RBRenameClassRefactoring >> storeOn: aStream [ 
	aStream nextPut: $(.
	self class storeOn: aStream.
	aStream nextPutAll: ' rename: '.
	class storeOn: aStream.
	aStream
		nextPutAll: ' to: #';
		nextPutAll: newName;
		nextPut: $)
]

{ #category : #transforming }
RBRenameClassRefactoring >> transform [
	self model 
		renameClass: class
		to: newName
		around: [self renameReferences]
]
