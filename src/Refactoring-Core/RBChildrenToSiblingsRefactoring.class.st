Class {
	#name : #RBChildrenToSiblingsRefactoring,
	#superclass : #RBClassRefactoring,
	#instVars : [
		'parent',
		'subclasses'
	],
	#category : #'Refactoring-Core-Refactorings'
}

{ #category : #'instance creation' }
RBChildrenToSiblingsRefactoring class >> model: aRBSmalltalk name: aClassName class: aClass subclasses: subclassCollection [ 
	^(self new)
		model: aRBSmalltalk;
		name: aClassName
			class: aClass
			subclasses: subclassCollection;
		yourself
]

{ #category : #'instance creation' }
RBChildrenToSiblingsRefactoring class >> name: aClassName class: aClass subclasses: subclassCollection [ 
	^(self new)
		name: aClassName
			class: aClass
			subclasses: subclassCollection;
		yourself
]

{ #category : #'private-accessing' }
RBChildrenToSiblingsRefactoring >> abstractSuperclass [
	^self model classNamed: className asSymbol
]

{ #category : #transforming }
RBChildrenToSiblingsRefactoring >> addSuperclass [
	self performComponentRefactoring: (RBAddClassRefactoring 
				model: self model
				addClass: className
				superclass: parent superclass
				subclasses: (Array with: parent)
				category: parent category)
]

{ #category : #transforming }
RBChildrenToSiblingsRefactoring >> changeIsKindOfReferences [
	| replacer |
	replacer := RBParseTreeRewriter new.
	replacer replace: '``@object isKindOf: ' , parent name
		with: '``@object isKindOf: ' , className.
	self convertAllReferencesToClass: parent using: replacer
]

{ #category : #'private-methods' }
RBChildrenToSiblingsRefactoring >> computeSubclassSupersOf: aClass [ 
	| selectors |
	selectors := Set new.
	aClass subclasses do: 
			[:each | 
			each selectors 
				do: [:sel | selectors addAll: (each parseTreeFor: sel) superMessages]].
	^selectors
]

{ #category : #'private-methods' }
RBChildrenToSiblingsRefactoring >> createSubclassResponsibilityFor: aSelector in: aClass [ 
	| source |
	(aClass superclass definesMethod: aSelector) ifTrue: [^self].
	source := self subclassResponsibilityFor: aSelector in: aClass.
	source isNil ifTrue: [^self].
	aClass superclass compile: source
		classified: (aClass protocolsFor: aSelector)
]

{ #category : #'initialize-release' }
RBChildrenToSiblingsRefactoring >> name: aClassName class: aClass subclasses: subclassCollection [ 
	className := aClassName asSymbol.
	parent := self model classFor: aClass.
	subclasses := subclassCollection 
				collect: [:each | self model classFor: each]
]

{ #category : #preconditions }
RBChildrenToSiblingsRefactoring >> preconditions [
	^subclasses 
		inject: ((RBCondition isMetaclass: parent) 
				errorMacro: 'Superclass must not be a metaclass') not 
				& (RBCondition isValidClassName: className) 
					& (RBCondition isGlobal: className in: self model) not
		into: 
			[:sub :each | 
			sub 
				& ((RBCondition isMetaclass: each) 
						errorMacro: 'Subclass must <1?not :>be a metaclass') not 
					& (RBCondition isImmediateSubclass: each of: parent)]
]

{ #category : #'private-variables' }
RBChildrenToSiblingsRefactoring >> pullUpClassInstanceVariables [
	| newSuperclass |
	newSuperclass := self abstractSuperclass theMetaClass.
	parent theMetaClass instanceVariableNames do: 
		[ :each | 
		self performComponentRefactoring: (RBPullUpInstanceVariableRefactoring 
				model: self model
				variable: each
				class: newSuperclass) ]
]

{ #category : #'private-variables' }
RBChildrenToSiblingsRefactoring >> pullUpClassVariables [
	| newSuperclass |
	newSuperclass := self abstractSuperclass.
	parent classVariableNames do: 
			[:each | 
			self performComponentRefactoring: (RBPullUpClassVariableRefactoring 
						model: self model
						variable: each
						class: newSuperclass)]
]

{ #category : #'private-variables' }
RBChildrenToSiblingsRefactoring >> pullUpInstanceVariables [
	| newSuperclass |
	newSuperclass := self abstractSuperclass.
	parent instanceVariableNames do: 
			[:each | 
			self performComponentRefactoring: (RBPullUpInstanceVariableRefactoring 
						model: self model
						variable: each
						class: newSuperclass)]
]

{ #category : #transforming }
RBChildrenToSiblingsRefactoring >> pullUpMethods [
	self pushUpMethodsFrom: parent.
	self pushUpMethodsFrom: parent theMetaClass
]

{ #category : #'private-variables' }
RBChildrenToSiblingsRefactoring >> pullUpPoolVariables [
	"Don't remove the pool variables from the subclass since they might be referenced there."

	| newSuperclass |
	newSuperclass := self abstractSuperclass.
	parent sharedPoolNames 
		do: [:each | newSuperclass addPoolDictionary: each]
]

{ #category : #'private-methods' }
RBChildrenToSiblingsRefactoring >> pushUp: aSelector in: aClass [ 
	| source |
	source := aClass sourceCodeFor: aSelector.
	source isNil 
		ifFalse: 
			[aClass superclass compile: source
				classified: (aClass protocolsFor: aSelector)]
]

{ #category : #'private-methods' }
RBChildrenToSiblingsRefactoring >> pushUpMethodsFrom: aClass [ 
	| selectorsToPushUp |
	selectorsToPushUp := self selectorsToPushUpFrom: aClass.
	aClass selectors do: 
			[:each | 
			(selectorsToPushUp includes: each) 
				ifTrue: [self pushUp: each in: aClass]
				ifFalse: [self createSubclassResponsibilityFor: each in: aClass]].
	selectorsToPushUp do: [:each | aClass removeMethod: each]
]

{ #category : #transforming }
RBChildrenToSiblingsRefactoring >> pushUpVariables [
	self pullUpInstanceVariables.
	self pullUpClassInstanceVariables.
	self pullUpClassVariables.
	self pullUpPoolVariables
]

{ #category : #transforming }
RBChildrenToSiblingsRefactoring >> reparentSubclasses [
	self model reparentClasses: subclasses to: self abstractSuperclass
]

{ #category : #'private-methods' }
RBChildrenToSiblingsRefactoring >> selectorsToPushUpFrom: aClass [ 
	| superSelectors |
	superSelectors := self computeSubclassSupersOf: aClass.
	^aClass selectors select: 
			[:each | 
			(superSelectors includes: each) or: [self shouldPushUp: each from: aClass]]
]

{ #category : #'private-methods' }
RBChildrenToSiblingsRefactoring >> shouldPushUp: aSelector from: aClass [ 
	^ ((aClass isMeta 
		ifTrue: [ subclasses collect: [ :each | each theMetaClass ] ]
		ifFalse: [ subclasses ]) 
		detect: [ :each | (each directlyDefinesMethod: aSelector) not ]
		ifNone: [ nil ]) notNil
]

{ #category : #printing }
RBChildrenToSiblingsRefactoring >> storeOn: aStream [ 
	aStream nextPut: $(.
	self class storeOn: aStream.
	aStream
		nextPutAll: ' name: #';
		nextPutAll: className;
		nextPutAll: ' class: '.
	parent storeOn: aStream.
	aStream nextPutAll: ' subclasses: '.
	subclasses asArray storeOn: aStream.
	aStream nextPut: $)
]

{ #category : #'private-methods' }
RBChildrenToSiblingsRefactoring >> subclassResponsibilityFor: aSelector in: aClass [ 
	| methodNode position source |
	source := aClass sourceCodeFor: aSelector.
	methodNode := RBParser parseMethod: source onError: [:err :pos | ^nil].
	position := methodNode arguments isEmpty 
				ifTrue: [methodNode keywordsIntervals last last ]
				ifFalse: [methodNode arguments last stop].
	^'<1s><n><t>self subclassResponsibility' 
		expandMacrosWith: (source copyFrom: 1 to: position)
]

{ #category : #transforming }
RBChildrenToSiblingsRefactoring >> transform [
	self
		addSuperclass;
		pushUpVariables;
		pullUpMethods;
		changeIsKindOfReferences;
		reparentSubclasses
]
