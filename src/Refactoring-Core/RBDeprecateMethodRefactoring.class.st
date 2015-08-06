"
A RBDeprecateMethodRefactoring is a class, that represents functionality of deprecate refactoring.

Instance Variables
	oldSelector	:	<Object>
	newSelector:		<Object>

oldSelector
	- is a selector which shouldn't be used anymore, it's deprecated
newSelector
	- is a selector which will be used instead of a deprecated one
	
Note: 
It is recommended to use this refactoring only if number of arguments is either equal in both selectors, or the new one has no arguments at all.
If new selector has fewer number of arguments than the old one, it may lead to unexpected results.
If you use it in other conditions an error may be be occured.
"
Class {
	#name : #RBDeprecateMethodRefactoring,
	#superclass : #RBMethodRefactoring,
	#instVars : [
		'oldSelector',
		'newSelector'
	],
	#category : #'Refactoring-Core-Refactorings'
}

{ #category : #'as yet unclassified' }
RBDeprecateMethodRefactoring class >> model: aRBSmalltalk deprecateMethod: aSelector in: aClass using: newSelector [
	^(self new)
		model: aRBSmalltalk;
		deprecateMethod: aSelector
			in: aClass
			using: newSelector;
		yourself
]

{ #category : #transforming }
RBDeprecateMethodRefactoring >> deprecateMethod: aSelector in: aClass using: newSel [
	oldSelector := aSelector.
	newSelector := newSel.
	class := self classObjectFor: aClass
]

{ #category : #transforming }
RBDeprecateMethodRefactoring >> formDeprecatedMethod [
	| oldName protocol newName deprecatedSource category |
	oldName := self formOldName.
	newName := self formNewName.
	protocol := (class methodFor: newSelector) protocols.
	class isMeta ifTrue: [ category := class realClass category ] ifFalse: [ category := class category ].
	deprecatedSource := oldName , String cr , String tab
		,
			'self 
		deprecated: ''Use ' , newSelector asString
		,
			' instead''
		on: 	''' , Date today asString
		,
			''' 
		in: ''' , category asString
		,
			'''.
	^ self ' , newName.
	(model classNamed: class realClass name) compile: deprecatedSource classified: protocol
]

{ #category : #transforming }
RBDeprecateMethodRefactoring >> formNameFor: aSelector [
	| method keywords arguments |
	method := class methodFor: aSelector.
	keywords := method parseTree keywords asOrderedCollection ifNil: [ '' ].
	arguments := method parseTree arguments ifNil: [ '' ].

	(keywords size >= 1 and: [ arguments size >= 1 ]) 
		ifTrue: [ ^ String streamContents: [ :s| 
			keywords with: arguments do: [ :keyword :arg | s nextPutAll: keyword, ' ', arg name, ' ' ] ] ]
		ifFalse: [ ^ aSelector asString ].
	

]

{ #category : #transforming }
RBDeprecateMethodRefactoring >> formNewName [
	^ self formNameFor: newSelector
]

{ #category : #transforming }
RBDeprecateMethodRefactoring >> formOldName [
	^ self formNameFor: oldSelector
]

{ #category : #transforming }
RBDeprecateMethodRefactoring >> formRewriteRule [
	| searchString oldKeywords oldArgs replaceString newKeywords newArgs |
	oldKeywords := (class methodFor: oldSelector) parseTree keywords asOrderedCollection ifNil: [ '' ].
	oldArgs := (class methodFor: oldSelector) parseTree arguments ifNil: [ '' ].
	newKeywords := (class methodFor: newSelector) parseTree keywords asOrderedCollection ifNil: [ '' ].
	newArgs := (class methodFor: newSelector) parseTree arguments ifNil: [ '' ].
	
	searchString := 'self '.
	
	(oldKeywords size >= 1 and: [ oldArgs size >= 1 ])
		ifTrue: [ 1 to: oldKeywords size do: [ :i | oldKeywords add: ' ``@arg' , i asString , ' ' afterIndex: 2 * i - 1 ] ].
	(oldKeywords size >= 1 and: [ oldArgs size >= 1 ])
		ifTrue: [ 1 to: oldKeywords size do: [ :i | searchString := searchString , (oldKeywords at: i) ] ]
		ifFalse: [ searchString := searchString , oldSelector asString ].
	replaceString := 'self '.
	(newKeywords size >= 1 and: [ newArgs size >= 1 ])
		ifTrue: [ 1 to: newKeywords size do: [ :i | newKeywords add: ' ``@arg' , i asString , ' ' afterIndex: 2 * i - 1 ] ].
	(newKeywords size >= 1 and: [ newArgs size >= 1 ])
		ifTrue: [ 1 to: newKeywords size do: [ :i | replaceString := replaceString , (newKeywords at: i) ] ]
		ifFalse: [ replaceString := replaceString , newSelector asString ].
	^ RBParseTreeRewriter new replace: searchString with: replaceString
]

{ #category : #preconditions }
RBDeprecateMethodRefactoring >> preconditions [
	| newCondition |
	newCondition := (RBCondition 
							withBlock: [oldSelector numArgs = newSelector numArgs or: [ newSelector numArgs = 0 ]]
							errorString: 'The new selectors should have the same number of arguments as the old one, or not have them at all').
	^newCondition
]

{ #category : #printing }
RBDeprecateMethodRefactoring >> storeOn: aStream [ 
	aStream nextPut: $(.
	self class storeOn: aStream.
	aStream
		nextPutAll: ' deprecateMethod: #';
		nextPutAll: oldSelector;
		nextPutAll: ' in: '.
	class storeOn: aStream.
	aStream
		nextPutAll: ' using: #';
		nextPutAll: newSelector.
	aStream nextPut: $)
]

{ #category : #transforming }
RBDeprecateMethodRefactoring >> transform [
	| methods subclassesMethods rewriter thisSubclasses |
	self formDeprecatedMethod.
	thisSubclasses := class allSubclasses.
	methods := class selectors asOrderedCollection.
	subclassesMethods := OrderedCollection new.
	rewriter := self formRewriteRule.
	methods
		do: [ :each | 
			(rewriter executeTree: (class methodFor: each) parseTree)
				ifTrue: [ class compileTree: rewriter tree ] ].
	thisSubclasses
		do: [ :eachSubclass | 
			eachSubclass selectors asOrderedCollection
				do: [ :each | 
					(rewriter executeTree: (eachSubclass methodFor: each) parseTree)
						ifTrue: [ eachSubclass compileTree: rewriter tree ] ] ]
]
