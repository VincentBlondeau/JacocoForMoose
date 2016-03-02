Class {
	#name : #JacocoClasspathOptimizer,
	#superclass : #MooseOperator,
	#category : #'Jacoco-TestSelection'
}

{ #category : #'as yet unclassified' }
JacocoClasspathOptimizer class >> optimiseFromFileNamed: toOptimize toFile: optimized separator: sep [
	| contents classPath stream |
	contents := toOptimize asFileReference readStream contents.
	classPath := (contents substrings: sep) allButFirst asSet.
	stream := optimized asFileReference writeStream.
	[ classPath do: [ :e | stream << e ] separatedBy: [ stream crlf ] ]
		ensure: [ stream close ]
]
