/******************************************************************************
 * Copyright 2018 The Apollo Authors. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *****************************************************************************/
#include <memory>

#include "cyber/class_loader/class_loader.h"
#include "cyber/component/component.h"
#include "cyber/examples/proto/examples.pb.h"
#include "cyber/component/timer_component.h"
using apollo::cyber::examples::proto::EChatter;
using apollo::cyber::Component;
using apollo::cyber::ComponentBase;
using apollo::cyber::TimerComponent;
using apollo::cyber::Writer;

class cal2 : public Component<EChatter,EChatter> {
 public:
  bool Init() override;
  bool Proc(const std::shared_ptr<EChatter>& msg0,
			const std::shared_ptr<EChatter>& msg1) override;
 private:
  std::shared_ptr<Writer<EChatter>> cal2_writer_ = nullptr;
};
CYBER_REGISTER_COMPONENT(cal2)
