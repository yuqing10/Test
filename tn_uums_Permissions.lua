--功能说明: 
--
--Copyright (C) 杭州塔网科技有限公司  2015-2020
--
--更新日志
--		 2025-04-28 新建   --by Eric
--------------------------------------------------
--#######变量定义开始
m_pTreeLoc = CLuaTreeUtil();
m_pTreeLoc:SetTree(ui:getDialogName(), 'id_tree_001');

m_pGrid = CLuaGridUtil();
m_pGrid:SetGrid(ui:getDialogName(), 'id_grid_001');



-- 查询系统节点，并设值到树上
function refreshSysTree()
	--clear_input();
    local helpSys = CSelectHelp();
	local helpRight = CSelectHelp();
	
	--查询系统人员
	local sql = [[select dept_name,dept_id,parent_dept_id,1 as isfolder ,
			'/picture/common/tree/com_tree_folder.png' as pic_path,'' as  selecctedimg from uums_dept
			union all
			select user_cn_name, user_id,dept_id ,0,'/picture/common/tree/com_tree_file.png','' from uums_user
				where user_name<>'admin' and user_name<>'sysadmin'
			]];
    db:select(sql,'', helpSys);
	

    ui:treeSetHelp('id_tree_001', helpSys);

end





function click_id_tree_001()
	--获取当前选中行
	--ui:treeSelectedNodes('id_tree_001',help);
	
	local X_Tree = m_pTreeLoc:getSelectedNode()
	
	--获取当前节点的is_f列数据
	--local tcol = m_pTreeLoc:getCurNodeType();
	
	--根据ID 返回ID对应节点的列的数据
	--local tName = m_pTreeLoc:getValue(X_Tree,tcol)
	TestHelp(X_Tree)
	
	
end



function TestHelp(user_id)

	local Usql = [[select DISTINCT 
    r.right_id as 权限ID,
    r.right_name as 权限名称,
    r.right_content as 权限内容,
    c.role_name as 角色名称
FROM 
    uums_right r WITH (NOLOCK)
INNER JOIN uums_role_right rr WITH (NOLOCK)
    ON r.right_id = rr.right_id
INNER JOIN uums_role c WITH (NOLOCK)
    ON rr.role_id = c.role_id
INNER JOIN uums_user_role ur WITH (NOLOCK)
    ON rr.role_id = ur.role_id 
    AND ur.user_id = '%s']];

	Usql = string.format(Usql,user_id)
	local uhelp = CSelectHelp();
	if db:select(Usql,"",uhelp)<0 then
		ui:tip("未查询到用户");
	end 
	ui:setHelp("id_grid_001",uhelp);
	
end









ui:setClickEvent('id_tree_001','click_id_tree_001');


--TestHelp()
refreshSysTree();
click_id_tree_001();






