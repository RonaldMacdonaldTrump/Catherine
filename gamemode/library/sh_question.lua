--[[
< CATHERINE > - A free role-playing framework for Garry's Mod.
Development and design by L7D.

Catherine is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Catherine.  If not, see <http://www.gnu.org/licenses/>.
]]--

catherine.question = catherine.question or { }
catherine.question.lists = { multipleChoice = { }, descriptive = { } }
CAT_QUESTION_MULTIPLE_CHOICE = 1
CAT_QUESTION_DESCRIPTIVE = 2

function catherine.question.RegisterMultipleChoice( title, answerList, answerIndex )
	catherine.question.lists.multipleChoice[ #catherine.question.lists.multipleChoice + 1 ] = {
		title = title,
		answerList = answerList,
		answerIndex = answerIndex
	}
end

function catherine.question.RegisterDescriptive( title, defVal )
	catherine.question.lists.descriptive[ #catherine.question.lists.descriptive + 1 ] = {
		title = title,
		defVal = defVal
	}
end

function catherine.question.GetAllMultipleChoice( )
	return catherine.question.lists.multipleChoice
end

function catherine.question.GetAllDescriptive( )
	return catherine.question.lists.descriptive
end

function catherine.question.FindByIndex( typ, index )
	if ( typ == CAT_QUESTION_MULTIPLE_CHOICE ) then
		return catherine.question.lists.multipleChoice[ index ]
	elseif ( typ == CAT_QUESTION_DESCRIPTIVE ) then
		return catherine.question.lists.descriptive[ index ]
	end
end

if ( SERVER ) then
	function catherine.question.InitializeData( pl )
		local data = {
			questions = { }
		}
		
		local questionType = catherine.question.GetQuestionType( )
		
		if ( questionType == CAT_QUESTION_MULTIPLE_CHOICE ) then
			local questions = catherine.question.GetAllMultipleChoice( )
			
			if ( #questions > 0 ) then
				data.questions = questions
			else
				print("Can't run - reason 1")
			end
		elseif ( questionType == CAT_QUESTION_DESCRIPTIVE ) then
			local questions = catherine.question.GetAllDescriptive( )
			
			if ( #questions > 0 ) then
				data.questions = questions
			else
				print("Can't run - reason 2")
			end
		end
	end
	
	function catherine.question.Check( pl, data )
		
	end
	
	function catherine.question.GetQuestionType( )
		return #catherine.util.GetAdmins( ) > 0 and CAT_QUESTION_DESCRIPTIVE or CAT_QUESTION_MULTIPLE_CHOICE
	end
else

end