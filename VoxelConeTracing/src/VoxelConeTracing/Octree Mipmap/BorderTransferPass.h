/*
 Copyright (c) 2012 The VCT Project

  This file is part of VoxelConeTracing and is an implementation of
  "Interactive Indirect Illumination Using Voxel Cone Tracing" by Crassin et al

  VoxelConeTracing is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  VoxelConeTracing is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with VoxelConeTracing.  If not, see <http://www.gnu.org/licenses/>.
*/

/*!
* \author Dominik Lazarek (dominik.lazarek@gmail.com)
* \author Andreas Weinmann (andy.weinmann@gmail.com)
*/

#ifndef VCT_SRC_VCT_BORDERTRANSFERPASS_H_
#define VCT_SRC_VCT_BORDERTRANSFERPASS_H_

#include "KoRE/Passes/ShaderProgramPass.h"
#include "VoxelConeTracing/Scene/VCTscene.h"


class BorderTransferPass : public kore::ShaderProgramPass
{
  public:
       BorderTransferPass(VCTscene* vctScene, 
                          EBrickPoolAttributes eBrickPool,
                          EThreadMode eThreadMode,
                          int level,
                          kore::EOperationExecutionType executionType);

    virtual ~BorderTransferPass(void);

  private:
    kore::ShaderProgram _shader;
    
    int _level;
    kore::ShaderData _shdLevel;

    uint _axisX;
    uint _axisY;
    uint _axisZ;
    uint _axisX_neg;
    uint _axisY_neg;
    uint _axisZ_neg;
    kore::ShaderData _shdAxisX;
    kore::ShaderData _shdAxisY;
    kore::ShaderData _shdAxisZ;
    kore::ShaderData _shdAxisX_neg;
    kore::ShaderData _shdAxisY_neg;
    kore::ShaderData _shdAxisZ_neg;
};

#endif //VCT_SRC_VCT_BORDERTRANSFERPASS_H_
