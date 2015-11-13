Class {
	#name : #JacocoSAXParser,
	#superclass : #SAXHandler,
	#instVars : [
		'className',
		'method',
		'result'
	],
	#category : #'Jacoco-Importer'
}

{ #category : #'as yet unclassified' }
JacocoSAXParser >> parsingResult [
	^ result
]

{ #category : #'as yet unclassified' }
JacocoSAXParser >> startDocument [
	result := OrderedCollection new
]

{ #category : #'as yet unclassified' }
JacocoSAXParser >> startElement: aQualifiedName attributes: aDictionary [
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
