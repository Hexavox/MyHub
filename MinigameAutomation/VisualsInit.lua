-- CLEAN UP OLD UI / VISUALS + CREATE FOLDERS

local oldGui = playerGui:FindFirstChild("WatermelonTrackerGui")
if oldGui then
    oldGui:Destroy()
end

local oldVisualFolder = Workspace:FindFirstChild(VISUAL_FOLDER_NAME)
if oldVisualFolder then
    oldVisualFolder:Destroy()
end

local oldPathFolder = Workspace:FindFirstChild(PATH_VISUAL_FOLDER_NAME)
if oldPathFolder then
    oldPathFolder:Destroy()
end

local visualFolder = Instance.new("Folder")
visualFolder.Name = VISUAL_FOLDER_NAME
visualFolder.Parent = Workspace

local pathVisualFolder = Instance.new("Folder")
pathVisualFolder.Name = PATH_VISUAL_FOLDER_NAME
pathVisualFolder.Parent = Workspace