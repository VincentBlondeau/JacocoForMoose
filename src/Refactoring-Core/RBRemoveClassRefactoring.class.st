Class {
	#name : #RBRemoveClassRefactoring,
	#superclass : #RBRefactoring,
	#instVars : [
		'classNames'
	],
	#category : #'Refactoring-Core-Refactorings'
}

{ #category : #'error messages' }
RBRemoveClassRefactoring class >> cannotRemoveTopLevelClassErrorMesssage [
	^ 'Cannot remove top level class', Character cr asString ,'when it has subclasses'
]

{ #category : #'instance creation' }
RBRemoveClassRefactoring class >> classNames: aClassNameCollection [ 
	^self new classNames: aClassNameCollection
]

{ #category : #'instance creation' }
RBRemoveClassRefactoring class >> model: aRBSmalltalk classNames: aClassNameCollection [ 
	^(self new)
		model: aRBSmalltalk;
		classNames: aClassNameCollection;
		yourself
]

{ #category : #'initialize-release' }
RBRemoveClassRefactoring >> classNames: aClassNameCollection [ 
	classNames := aClassNameCollection
]

{ #category : #preconditions }
RBRemoveClassRefactoring >> environmentWithReferencesTo: aClass [
	^ RBBrowserEnvironment new 
		referencesTo: (Smalltalk globals 
			associationAt: aClass 
			ifAbsent: [ aClass ])
]

{ #category : #preconditions }
RBRemoveClassRefactoring >> environmentWithUsersOf: aTrait [
	^ RBClassEnvironment 
		onEnvironment: RBBrowserEnvironment new
		classes: aTrait realClass users
]

{ #category : #preconditions }
RBRemoveClassRefactoring >> hasReferencesTo: aSymbol [ 
	| literal |
	literal := Smalltalk globals associationAt: aSymbol.
	RBBrowserEnvironment new classesDo: 
			[:each | 
			(classNames 
				includes: (each isMeta ifTrue: [each soleInstance] ifFalse: [each]) name) 
					ifFalse: 
						[(each whichSelectorsReferTo: literal) isEmpty ifFalse: [^true].
						(each whichSelectorsReferTo: aSymbol) isEmpty ifFalse: [^true]]].
	^false
]

{ #category : #preconditions }
RBRemoveClassRefactoring >> preconditionHasNoReferences: aClass [
	^ (RBCondition withBlock: [ (self hasReferencesTo: aClass asSymbol) not ])
		errorMacro: aClass , ' is referenced.<n>Browse references?';
		errorBlock: [ self openBrowserOn: (self environmentWithReferencesTo: aClass) ];
		yourself
]

{ #category : #preconditions }
RBRemoveClassRefactoring >> preconditionHasNoSubclasses: aClass [
	^ (RBCondition withBlock: [ aClass subclasses isEmpty ])
		errorMacro: self class cannotRemoveTopLevelClassErrorMesssage;
		yourself
]

{ #category : #preconditions }
RBRemoveClassRefactoring >> preconditionHasNoUsers: aClassOrTrait [
	^ (RBCondition withBlock: [ aClassOrTrait realClass users isEmpty ])
		errorMacro: aClassOrTrait name , ' Trait is used.<n>Browse classes using it?';
		errorBlock: [ self openBrowserOn: (self environmentWithUsersOf: aClassOrTrait) ];
		yourself
]

{ #category : #preconditions }
RBRemoveClassRefactoring >> preconditionIsNotMetaclass: aClass [
	^ ((RBCondition isMetaclass: aClass) errorMacro: 'Cannot remove just the metaclass') not
]

{ #category : #preconditions }
RBRemoveClassRefactoring >> preconditions [
	^ classNames
		inject: RBCondition empty
		into: [ :sum :each | 
			| aClassOrTrait |
			aClassOrTrait := self model classNamed: each asSymbol.
			aClassOrTrait isNil
				ifTrue: [ self refactoringFailure: 'No such class or trait' ].
			sum
				& ( (self preconditionIsNotMetaclass: aClassOrTrait) 
					& (self preconditionHasNoReferences: each)
					& (self preconditionHasNoSubclasses: aClassOrTrait)
					& (self preconditionHasNoUsers: aClassOrTrait ) ) ]
]

{ #category : #transforming }
RBRemoveClassRefactoring >> removeClasses [
	classNames do: [:each | self model removeClassNamed: each]
]

{ #category : #transforming }
RBRemoveClassRefactoring >> reparentSubclasses [
	classNames do: 
			[:each | 
			| class |
			class := self model classNamed: each.
			self model reparentClasses: class subclasses copy to: class superclass]
]

{ #category : #printing }
RBRemoveClassRefactoring >> storeOn: aStream [ 
	aStream nextPut: $(.
	self class storeOn: aStream.
	aStream nextPutAll: ' classNames: '.
	classNames asArray storeOn: aStream.
	aStream nextPut: $)
]

{ #category : #transforming }
RBRemoveClassRefactoring >> transform [
	self
		reparentSubclasses;
		removeClasses
]
