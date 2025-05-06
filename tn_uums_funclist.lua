--功能说明: 
--
--Copyright (C) 杭州塔网科技有限公司  2015-2020
--
--更新日志
--		 2025-04-30 新建   --by li
--------------------------------------------------
--#######变量定义开始

local treeSys = CLuaTreeUtil();
treeSys:SetTree(ui:getDialogName(),'id_sys_tree');


local m_pGridUser = CLuaGridUtil();
m_pGridUser:SetGrid(ui:getDialogName(),'id_grid_user');

local m_helpUserRole = CSelectHelp();








function refreshSysTree()
	--clear_input();
    local helpSys = CSelectHelp();
	local helpRight = CSelectHelp();
	--查询系统及模块
	local sql = [[select sys_name,sys_id,parent_sys_id,param_col1 as is_forder,param_col2 as pic_path,'' as selecctedimg,sort from (
			select sys_id,parent_sys_id,sys_name,1 as param_col1,'/picture/common/tree/com_tree_folder.png' as param_col2,
			'' as selectedimg,sort from uums_sys  where  sys_id<>1 and  ( parent_sys_id<>1  or parent_sys_id is null ) and (is_hide is null or is_hide=0 )
		union all 
		 select t1.right_id ,t1.sys_id,t1.right_name,0 as param_col1,'/picture/common/tree/com_tree_file.png' as param_col2,
		 '' as selectedimg,t1.sort from uums_right t1 left join uums_sys t2 on t1.root_sys_id=t2.sys_id 
			 where t1.root_sys_id>1 and t2.is_hide is null or   t2.is_hide=0 ) t order by sys_name
			]];
    db:select(sql,'', helpSys);
	
	helpSys:sortV2('sort');
    ui:treeSetHelp('id_sys_tree', helpSys);
    
end


--查看内容
function click_tree(name,id,parentID)
	--获取当前选中行
	--ui:treeSelectedNodes('id_tree_001',help);
	
	local X_Tree = treeSys:getSelectedNode()
	print(X_Tree)
	
	--获取当前节点的is_f列数据
	--local tcol = treeSys:getCurNodeType();
	
	--根据ID 返回ID对应节点的列的数据
	--local tName = treeSys:getValue(X_Tree,tcol)
	get_role_user(X_Tree)
	
end



--查询拥有该权限的人员
function get_role_user(sRightID)
	local sql = [[
			SELECT
				a.USER_ID,
				b.USER_CN_NAME ,
				c.ROLE_NAME,
				d.DEPT_NAME,
				b.dept_id
			FROM
				uums_user_role a WITH ( NOLOCK )
				LEFT JOIN uums_user b WITH ( NOLOCK ) ON a.USER_ID = b.USER_ID
				LEFT JOIN uums_role c WITH ( NOLOCK ) ON a.ROLE_ID = c.ROLE_ID
				LEFT JOIN uums_dept d WITH ( NOLOCK ) ON b.DEPT_ID = d.DEPT_ID 
			WHERE
				a.ROLE_ID IN (
				SELECT
					ROLE_ID 
				FROM
					uums_role_right a WITH ( NOLOCK )
				WHERE
					a.RIGHT_ID = '%s')
					AND b.is_delete = 0;
	]]
	
	Usql = string.format(sql,sRightID)
	
	local righthelp = CSelectHelp();
	
	if db:select(Usql, '', righthelp) < 0 then
		ui:tip("查询失败");
	end
	m_pGridUser:setHelp(righthelp);
	
	local Tsql = [[
			SELECT
				DEPT_ID,
				DEPT_NAME,
				parent_dept_id
			FROM
				uums_dept WITH ( NOLOCK )
			WHERE
				1 = 1
			order by dept_id
	]]
	
	Psql = string.format(sql,sRightID);
	
	local Thelp = CSelectHelp();
	
	if db:select(Psql, '', Thelp) < 0 then
		ui:tip("查询失败");
	end
	m_pGridUser:setHelp(Thelp);
	
	
	
end





--树点击事件
ui:setClickEvent('id_sys_tree','click_tree');
--ui:setClickEvent('id_refresh','refreshSysTree');


refreshSysTree();

click_tree();








































