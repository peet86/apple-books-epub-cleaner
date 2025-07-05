-- EPUB Cleaner AppleScript
-- This script cleans epub files by removing iTunesMetadata.plist

on run {input, parameters}
	return cleanEpubFiles(input)
end run

on cleanEpubFiles(fileList)
	set processedCount to 0
	set failedCount to 0
	set cleanedFiles to {}
	
	-- Get the directory of this script to find the shell script
	set scriptPath to (path to me as string)
	set scriptDir to (do shell script "dirname " & quoted form of POSIX path of scriptPath)
	set shellScriptPath to scriptDir & "/clean_epub.sh"
	
	-- Make sure shell script is executable
	try
		do shell script "chmod +x " & quoted form of shellScriptPath
	end try
	
	repeat with fileItem in fileList
		set filePath to POSIX path of fileItem
		
		-- Check if it's an epub file
		if filePath ends with ".epub" then
			try
				-- Call the shell script
				set result to do shell script quoted form of shellScriptPath & " " & quoted form of filePath
				set processedCount to processedCount + 1
				
				-- Find the cleaned file path
				set fileName to do shell script "basename " & quoted form of filePath & " .epub"
				set fileDir to do shell script "dirname " & quoted form of filePath
				set cleanedFilePath to fileDir & "/" & fileName & "_cleaned.epub"
				set end of cleanedFiles to cleanedFilePath
				
			on error errorMessage
				set failedCount to failedCount + 1
				log "Failed to process " & filePath & ": " & errorMessage
			end try
		end if
	end repeat
	
	-- Show summary dialog
	set summaryMessage to "EPUB Cleaner Results:" & return & return
	set summaryMessage to summaryMessage & "Processed: " & processedCount & " files" & return
	set summaryMessage to summaryMessage & "Failed: " & failedCount & " files" & return
	
	if processedCount > 0 then
		set summaryMessage to summaryMessage & return & "Cleaned files have been saved with '_cleaned' suffix."
	end if
	
	display dialog summaryMessage with title "EPUB Cleaner" buttons {"OK"} default button "OK"
	
	-- Return the cleaned files for further processing if needed
	return cleanedFiles
end cleanEpubFiles

-- Handle direct file drops
on open droppedFiles
	cleanEpubFiles(droppedFiles)
end open 