pragma solidity ^0.4.0;

contract  CreateVote
{
	address public chairmanAdr;			//申明投票发起人————会长chairman
	
	//投票人的结构体
	struct voter
	{
		uint weight=1;						//投票人的权重，默认一人一票
		address delegaterAdr;				//代理人的地址
	}
	mapping(address=>voter) public voters; //将地址映射到投票人


	//可投选项
	struct  option
	{
		uint   id;					 //项目号（0，1，2，3···）
		bytes8  name;				//项目名称
		uint count;					//项目得票数
	}
	option[]  public options;      //所以的项目


	//构造函数，由会长发起投票
	fuction CreateVote(string description, bytes8[] optionName)
	{
		string public description=description;					//描述投票项目的内容
		chairmanAdr= msg.sender;
		for(unit i=0; i< optionName.length; i++)
		{
			options.push(option({id：i, name: optionName[i], count: 0}));
		}
	}


	//设置一个修改器，有的权限只有合约拥有者才能有
	modifier onlyOwner
	{
		if(msg.sender != chairmanAdr)
		{
			throw;
		}
		else
		{
			_;
		}
	}


	//合约拥有人可以让合约自毁
	function killVote(address reception) onlyOwner
	{
			selfdestruct(reception);
	}


	//合约拥有人可以转让合约
	function transferVote(address reception) onlyOwner
	{
		chairmanAdr=reception;
	}


	//找人代理投票
	function delegate(address toAdr)
	{
		voter senter = voters[msg.sender];
		if(senter.weight==0)					//如果已经投过票了
		{
			throw;
		}
		
		while(voters[toAdr].delegaterAdr != address(0))   //当代理人还找了代理人
		{
			toAdr=voters[toAdr].delegaterAdr;
			if(toAdr==msg.sender)				//如果代理人的代理人，居然是自己
			{
				throw;
			}
		}

		senter.delegaterAdr=toAdr;    //成功找到代理人
		senter.weight=0;			//自己的投票权重消失，不能再投票

		voter delegater= voters[toAdr];      //代理人
		delegater.weight+= senter.weight;	//代理人的投票权重提升
	}


	event e(bytes8 _optionName, uint _count);		//设置事件来监听投票结果

	//代理人专用的投票函数
	fuction vote(uint id, uint _weight)
	{
		voter senter= voters[msg.sender];
		if(senter.weight<_weight)
		{
			throw;
		}
		else
		{
			senter.weight -=_weight;
			options[id].count += _weight;
		}
		for(uint i=0; i< options.length ; i++)
		{
			e(options[i].optionName, options[i].count);
		}
	}


	//普通人的投票函数
	fuction vote(uint id)
	{
		voter senter= voters[msg.sender];
		if(senter.weight==0)
		{
			throw;
		}
		else
		{
			senter.weight -=1;
			options[id].count += 1;
		}
		for(uint i=0; i< options.length ; i++)
		{
			e(options[i].optionName, options[i].count);
		}
	}

}