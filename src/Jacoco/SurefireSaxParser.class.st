Class {
	#name : #SurefireSaxParser,
	#superclass : #SAXHandler,
	#instVars : [
		'result'
	],
	#category : #'Jacoco-Surefire'
}

{ #category : #'as yet unclassified' }
SurefireSaxParser >> parsingResult [
	^ result
]

{ #category : #'as yet unclassified' }
SurefireSaxParser >> startDocument [
	result := OrderedCollection new
]

{ #category : #'as yet unclassified' }
SurefireSaxParser >> startElement: aQualifiedName attributes: aDictionary [
	| className |
	aQualifiedName = 'class'
		ifTrue: [ className := aDictionary at: 'name' ].
	aQualifiedName = 'method'
		ifTrue:
			[ 
			result
				add:
					{(#className -> className).
					(#methodName -> (aDictionary at: 'name')).
					(#methodSignature -> (aDictionary at: 'desc'))} asDictionary ]
]
